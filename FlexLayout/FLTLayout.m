//
//  FLTLayout.m
//  FlexLayout
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <FlexLayout/FLTLayout.h>
#import <FlexLayout/FLTNode+Private.h>

@interface FLTLayout ()
@property (strong, nonatomic, readwrite) FLTNode *node;
@property (copy, nonatomic, readwrite) NSArray *children;
@end

@implementation FLTLayout


#pragma mark - Lifecycle

- (instancetype)initWithNode:(FLTNode *)node children:(NSArray *)children
{
    self = [super init];
    if (self == nil) { return self; }
    
    _node = node;
    _children = [children copy];
    
    return self;
}


#pragma mark - Getter and Setter

- (CGRect)frame
{
    return self.node.frame;
}


#pragma mark - Apply Layout to Views

- (void)layoutForSize:(CGSize)size
{
    // Update root node size for relayout
    FLTNode *node = self.node;
    node.node->style.dimensions[CSS_WIDTH] = size.width;
    node.node->style.dimensions[CSS_HEIGHT] = size.height;
    
    // Layout node hirarchie
    [node layoutWithMaxWidth:size.width];
}

- (void)layoutViews
{
    // Update node view frame
    self.node.view.frame = CGRectIntegral(self.frame);
    
    // Layout all subviews
    for (FLTLayout *layout in self.children) {
        [layout layoutViews];
    }
}

- (void)applyToView:(FLTNodeView *)view
{
    // Layout top view
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        [[view animator] setFrame:CGRectIntegral(self.frame)];
    } completionHandler:^{
        
    }];
    
    // Layout all subviews
    NSArray *subviews  = view.subviews;
    NSArray *children = self.children;
    NSInteger minIndex = MIN(subviews.count, children.count);
    for (NSInteger i = 0; i < minIndex; i++) {
        FLTNodeView *subview = subviews[i];
        FLTLayout *layout = children[i];
        [layout applyToView:subview];
    }
}


#pragma mark - Description

- (NSString *)description
{
    return [self descriptionForDepth:0];
}

- (NSString *)descriptionForDepth:(NSInteger)depth
{
    NSString *description = [NSString stringWithFormat:@"{origin={%f, %f}, size={%f, %f}}", CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)];
    
    if (self.children.count > 0) {
        
        // Indentation for current depth
        NSMutableString *indentation = [NSMutableString string];
        for (NSInteger i = 0; i < depth+1; i++) {
            [indentation appendFormat:@"\t"];
        }
        
        // Print out children
        NSMutableString *childrenDescripton = [NSMutableString stringWithFormat:@"%@ ", description];
        for (FLTLayout *child in self.children) {
            NSString *childDescription  = [child descriptionForDepth:depth+1];
            [childrenDescripton appendFormat:@"\n%@%@", indentation, childDescription];
        }
        return childrenDescripton;
    }
    
    return description;
}

@end