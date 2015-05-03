//
//  FLTNode.m
//  FlexLayout
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <FlexLayout/FLTNode.h>
#import <FlexLayout/Layout.h>
#import <FlexLayout/FLTLayout.h>
#import <FlexLayout/FLTNode+Private.h>

#pragma mark - MISFlexLayoutNode

const CGFloat FLTNodeUndefinedValue = NAN;
const FLTEdgeInsets NodeEdgeInsetsZero = (FLTEdgeInsets){0, 0, 0, 0};


@interface FLTNode ()
@property (strong, nonatomic, readwrite) FLTNodeView *view;
@property (assign, nonatomic, readwrite) CGSize size;
@property (copy, nonatomic, readwrite) NSArray *children;
@property (assign, nonatomic, readwrite) FLTNodeDirection direction;
@property (assign, nonatomic, readwrite) FLTEdgeInsets margin;
@property (assign, nonatomic, readwrite) FLTEdgeInsets padding;
@property (assign, nonatomic, readwrite) BOOL wrap;
@property (assign, nonatomic, readwrite) FLTNodeJustification justification;
@property (assign, nonatomic, readwrite) FLTNodeSelfAlignment selfAlignment;
@property (assign, nonatomic, readwrite) FLTNodeChildAlignment childAlignment;
@property (assign, nonatomic, readwrite) CGFloat flex;
@property (copy, nonatomic, readwrite) CGSize (^measure)(CGFloat width);

- (instancetype)initWithNodeBuilder:(FLTNodeBuilder *)nodeBuilder;

@end


static bool alwaysDirty(void *context) {
	return true;
}

static css_node_t * getChild(void *context, int i) {
	FLTNode *self = (__bridge FLTNode *)context;
	FLTNode *child = self.children[i];
	return child.node;
}

static css_dim_t measureNode(void *context, float width) {
	FLTNode *self = (__bridge FLTNode *)context;
	CGSize size = self.measure(width);
	return (css_dim_t){ size.width, size.height };
}


#pragma mark - NodeBuilder

@implementation FLTNodeBuilder

- (instancetype)init
{
    self = [super init];
    if (self == nil) { return self; }
    
    // Default values for Node
    _size = CGSizeMake(FLTNodeUndefinedValue, FLTNodeUndefinedValue);
    _direction = FLTNodeDirectionColumn;
    _margin = NodeEdgeInsetsZero;
    _padding = NodeEdgeInsetsZero;
    _wrap = NO;
    _justification = FLTNodeJustificationFlexStart;
    _selfAlignment = FLTNodeSelfAlignmentAuto;
    _childAlignment = FLTNodeChildAlignmentStretch;
    _flex = 0.0;
    
    return self;
}

- (FLTNode *)build
{
    return [[FLTNode alloc] initWithNodeBuilder:self];
}

@end


@implementation FLTNode {
    css_node_t *_node;
}

#pragma mark - Class

+ (instancetype)nodeWithBlock:(void (^)(FLTNodeBuilder *nodeBuilder))block
{
    NSParameterAssert(block);

    FLTNodeBuilder *nodeBuilder = [FLTNodeBuilder new];
    block(nodeBuilder);
    return [nodeBuilder build];
}


#pragma mark - Lifecycle

- (void)dealloc {
	free_css_node(_node);
}

- (instancetype)initWithNodeBuilder:(FLTNodeBuilder *)nodeBuilder
{
    self = [super init];
    if (self == nil) { return self; }
    
    _view = nodeBuilder.view;
    _size = nodeBuilder.size;
    _children = [nodeBuilder.children copy];
    _direction = nodeBuilder.direction;
    _margin = nodeBuilder.margin;
    _padding = nodeBuilder.padding;
    _wrap = nodeBuilder.wrap;
    _justification = nodeBuilder.justification;
    _selfAlignment = nodeBuilder.selfAlignment;
    _childAlignment = nodeBuilder.childAlignment;
    _flex = nodeBuilder.flex;
    _measure = [nodeBuilder.measure copy];
    
    [self createUnderlyingNode];
    
    return self;
}

- (void)createUnderlyingNode
{
    _node = new_css_node();
    _node->context = (__bridge void *)self;
    _node->is_dirty = alwaysDirty;
    _node->get_child = getChild;
    
    _node->style.dimensions[CSS_WIDTH] = self.size.width;
    _node->style.dimensions[CSS_HEIGHT] = self.size.height;
    
    _node->style.margin[CSS_LEFT] = self.margin.left;
    _node->style.margin[CSS_RIGHT] = self.margin.right;
    _node->style.margin[CSS_TOP] = self.margin.top;
    _node->style.margin[CSS_BOTTOM] = self.margin.bottom;
    
    _node->style.padding[CSS_LEFT] = self.padding.left;
    _node->style.padding[CSS_RIGHT] = self.padding.right;
    _node->style.padding[CSS_TOP] = self.padding.top;
    _node->style.padding[CSS_BOTTOM] = self.padding.bottom;
    
    _node->style.flex = self.flex;
    _node->style.flex_direction = (css_flex_direction_t)self.direction;
    _node->style.flex_wrap = (css_wrap_type_t)(self.wrap ? 1 : 0);
    _node->style.justify_content = (css_justify_t)self.justification;
    _node->style.align_self = (css_align_t)self.selfAlignment;
    _node->style.align_items = (css_align_t)self.childAlignment;
    
    _node->children_count = (int)self.children.count;
    _node->measure = (_measure != nil ? measureNode : NULL);
}


#pragma mark - Getter / Setter

- (css_node_t *)node
{
    return _node;
}

- (CGRect)frame
{
	return CGRectMake(self.node->layout.position[CSS_LEFT],
                      self.node->layout.position[CSS_TOP],
                      self.node->layout.dimensions[CSS_WIDTH],
                      self.node->layout.dimensions[CSS_HEIGHT]);
}


#pragma mark - Layout Node

- (void)layout
{
	[self layoutWithMaxWidth:CSS_UNDEFINED];
}

- (void)layoutWithMaxWidth:(CGFloat)maxWidth
{
	[self prepareForLayout];

	layoutNode(self.node, maxWidth);
    
}

- (void)prepareForLayout
{
	for (FLTNode *child in self.children) {
		[child prepareForLayout];
	}

	// Apparently we need to reset these before laying out, otherwise the layout
	// has some weird additive effect.
	self.node->layout.position[CSS_LEFT] = 0;
	self.node->layout.position[CSS_TOP] = 0;
	self.node->layout.dimensions[CSS_WIDTH] = CSS_UNDEFINED;
	self.node->layout.dimensions[CSS_HEIGHT] = CSS_UNDEFINED;
}


#pragma mark - Build Layout From Node

static NSArray *createLayoutsFromChildren(FLTNode *node)
{
    NSMutableArray *nodeChildren = [NSMutableArray array];
    for (FLTNode *child in [node children]) {
        NSArray *children = createLayoutsFromChildren(child);
        FLTLayout *layout = [[FLTLayout alloc] initWithNode:child children:children];
        [nodeChildren addObject:layout];
    }
    return nodeChildren;
}

- (FLTLayout *)buildLayout
{
    return [self buildLayoutWithMaxWidth:-1];
}

- (FLTLayout *)buildLayoutWithMaxWidth:(CGFloat)maxWidth
{
    FLTNode *node = self;
    if (maxWidth < 0) {
        [node layout];
    } else {
        [node layoutWithMaxWidth:maxWidth];
    }

    NSArray *children = createLayoutsFromChildren(node);
    return [[FLTLayout alloc] initWithNode:node children:children];
}

@end

#pragma mark - Helper Functions

FLTNode *FLTNodeMake(void(^block)(FLTNodeBuilder *nodeBuilder)) {
    return [FLTNode nodeWithBlock:block];
}