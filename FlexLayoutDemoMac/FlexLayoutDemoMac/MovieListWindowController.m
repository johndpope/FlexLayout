//
//  MovieListWindowController.m
//  FlexLayoutDemoMac
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import "MovieListWindowController.h"
#import <FlexLayout/FlexLayout.h>
#import "MISFlippedView.h"
#import "MovieModel.h"


#pragma mark - MovieListTableViewCellView

@interface MovieListTableViewCellView : MISFlippedView
@property (strong, nonatomic) MISFlippedView *containerView;
@property (strong, nonatomic) NSTextField *titleTextField;
@property (strong, nonatomic) NSImageView *posterImageView;
@property (strong, nonatomic) NSTextField *descriptionTextField;

@property (assign, nonatomic, getter=isTemporary) BOOL temporary;

@property (strong, nonatomic) MovieModel *movieModel;
@property (strong, nonatomic) FLTLayout *layout;

@end

@implementation MovieListTableViewCellView


#pragma mark - Lifecycle

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) { return nil; }
    [self initView];
    return self;
}

- (void)initView
{
    _titleTextField = ({
        NSTextField *textField = [[NSTextField alloc] initWithFrame:NSZeroRect];
        textField.editable = NO;
        textField.font = [NSFont boldSystemFontOfSize:18.0];
        textField.bezeled = NO;
        textField.lineBreakMode = NSLineBreakByWordWrapping;
        textField.drawsBackground = NO;
        [self addSubview:textField];
        textField;
    });

    _containerView = [[MISFlippedView alloc] initWithFrame:CGRectZero];

    _posterImageView = ({
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:CGRectZero];
        imageView.imageScaling = NSImageScaleAxesIndependently;
        [_containerView addSubview:imageView];
        imageView;
    });

    _descriptionTextField = ({
        NSTextField *textField = [[NSTextField alloc] initWithFrame:NSZeroRect];
        textField = [[NSTextField alloc] initWithFrame:NSZeroRect];
        textField.editable = NO;
        textField.font = [NSFont systemFontOfSize:14.0];
        textField.bezeled = NO;
        textField.lineBreakMode = NSLineBreakByWordWrapping;
        textField.drawsBackground = NO;
        [_containerView addSubview:textField];
        textField;
    });
    
    [self addSubview:_containerView];
}


#pragma mark - Reuse

- (void)viewDidMoveToSuperview
{
    if (self.superview == nil) {
        [self mis_prepareForReuse];
    }
    
    [super viewDidMoveToSuperview];
}

- (void)mis_prepareForReuse
{
    [self.movieModel cancelFetchPoster];
    
    self.titleTextField.stringValue = @"";
    self.descriptionTextField.stringValue = @"";
    self.posterImageView.image = nil;
}


#pragma mark - Setter / Getter

- (void)setMovieModel:(MovieModel *)data
{
    [data cancelFetchPoster];
    
    _movieModel = data;
    
    self.titleTextField.stringValue = data.title;
    self.descriptionTextField.stringValue = data.plot;
    
    [self loadImage];
}


#pragma mark - Layout

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
    [super resizeSubviewsWithOldSize:oldSize];
    
    if (self.isTemporary) { return; }
    
    // The view already has the right size so just layout based on bounds
    [self.layout layoutForSize:self.bounds.size];
    
    // Layout all views based on layout
    [self.layout layoutViews];
}

- (CGFloat)rowHeight
{
    // Let layout figure out necessary row height
    [self.layout layoutForSize:CGSizeMake(CGRectGetWidth(self.bounds), FLTNodeUndefinedValue)];
    return CGRectGetHeight(self.layout.frame);
}


#pragma mark - Image

- (void)loadImage
{
    if (self.isTemporary) { return; }
    
    [self.movieModel fetchPoster:^(NSImage *image) {
        self.posterImageView.image = image;
    }];
}

@end


#pragma mark - MovieListWindowController

typedef enum : NSUInteger {
    LayoutStyleRow,
    LayoutStyleColumn
} LayoutStyle;

@interface MovieListWindowController () <NSTableViewDataSource, NSTableViewDelegate>
@property (assign, nonatomic) LayoutStyle layoutStyle;

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSSegmentedControl *layoutStyleSegmentedControl;

@property (copy, nonatomic) NSArray *listOfMovies;
@property (strong, nonatomic) MovieListTableViewCellView *cellViewForRowHeightCalculation;
@end

@implementation MovieListWindowController


#pragma mark - Lifecycle

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    _layoutStyle = LayoutStyleRow;
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewContentBoundsDidChange:) name:NSViewFrameDidChangeNotification object:self.tableView.enclosingScrollView.contentView];

    self.layoutStyleSegmentedControl.selectedSegment = self.layoutStyle;
    [self.layoutStyleSegmentedControl setTarget:self];
    [self.layoutStyleSegmentedControl setAction:@selector(segmentedControlChanged:)];
    
    self.cellViewForRowHeightCalculation = ({
        MovieListTableViewCellView *cellView = [MovieListTableViewCellView new];
        cellView.temporary = YES;
        cellView;
    });
    
    // Sample data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *moviesList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSMutableArray *dataArray = [NSMutableArray array];
    [moviesList enumerateObjectsUsingBlock:^(NSDictionary *movieDictionary, NSUInteger idx, BOOL *stop) {
        MovieModel *movie = [MovieModel movieWithDictionary:movieDictionary];
        [dataArray addObject:movie];
    }];
    self.listOfMovies = dataArray;
    
    [self.tableView reloadData];
}


#pragma mark - Notifications / Actions

- (void)scrollViewContentBoundsDidChange:(NSNotification*)notification
{
    // Resize table view cells if window resizes
    NSRange rows = NSMakeRange(0, self.tableView.numberOfRows);
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0];
    [self.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:rows]];
    [NSAnimationContext endGrouping];
}

- (void)segmentedControlChanged:(id)sender
{
    self.layoutStyle = (LayoutStyle)self.layoutStyleSegmentedControl.selectedSegment;
    [self.tableView reloadData];
}


#pragma mark - Configure cell view

- (void)configureCellView:(MovieListTableViewCellView *)cellView row:(NSInteger)row
{
    if (cellView == nil) { return; }

    cellView.movieModel = self.listOfMovies[row];
    cellView.layout = self.layoutStyle == LayoutStyleRow ? [self rowLayoutForCellView:cellView]
                                                         : [self columnLayoutForCellView:cellView];
}

- (FLTLayout *)rowLayoutForCellView:(MovieListTableViewCellView *)cellView
{
    // Use weak to prevent retainCycle in measure block
    __weak MovieListTableViewCellView *weakCellView = cellView;
    
    static CGFloat minHeight = 200.0;
    
    FLTNode *parent = FLTNodeMake(^(FLTNodeBuilder *n) {
        n.direction = FLTNodeDirectionColumn;
        n.padding = FLTEdgeInsetsMake(20.0, 10.0, 0.0, 10.0);
        n.children = @[
            FLTNodeMake(^(FLTNodeBuilder *n) {
                n.view = cellView.titleTextField,
                n.measure = ^CGSize(CGFloat width) {
                    if (isnan(width)) { return CGSizeZero; }
                    return [weakCellView.titleTextField sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)];
                };
            }),
            FLTNodeMake(^(FLTNodeBuilder *n) {
                n.view = cellView.containerView,
                n.direction = FLTNodeDirectionRow;
                n.padding = FLTEdgeInsetsMakeUniform(20);
                n.children = @[
                    FLTNodeMake(^(FLTNodeBuilder *n) {
                        n.view = cellView.posterImageView,
                        n.size = CGSizeMake(200.0, FLTNodeUndefinedValue);
                    }),
                    FLTNodeMake(^(FLTNodeBuilder *n) {
                        n.flex = 1;
                        n.view = cellView.descriptionTextField,
                        n.margin = FLTEdgeInsetsMake(0, 20.0, 0, 0);
                        n.measure = ^CGSize(CGFloat width) {
                            if (isnan(width)) { return CGSizeZero; }
                            CGSize descriptionSize = [weakCellView.descriptionTextField sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)];
                            descriptionSize.height = MAX(descriptionSize.height, minHeight);
                            return descriptionSize;
                        };
                    }),
                ];
            })
        ];
    });
    
    return [parent buildLayout];
}

- (FLTLayout *)columnLayoutForCellView:(MovieListTableViewCellView *)cellView
{
    // Use weak to prevent retainCycle in measure block
    __weak MovieListTableViewCellView *weakCellView = cellView;
    FLTNode *parent = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.direction = FLTNodeDirectionColumn;
        n.padding = FLTEdgeInsetsMake(20.0, 10.0, 0.0, 10.0);
        n.children = @[
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = cellView.titleTextField,
                n.measure = ^CGSize(CGFloat width) {
                    if (isnan(width)) { return CGSizeZero; }
                    return [weakCellView.titleTextField sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)];
                };
            }],
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = cellView.containerView,
                n.direction = FLTNodeDirectionColumn;
                n.padding = FLTEdgeInsetsMake(20, 20, 20, 20);
                n.children = @[
                    [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                        n.view = cellView.posterImageView,
                        n.margin = FLTEdgeInsetsMake(0, 0, 10, 0);
                        n.size = CGSizeMake(FLTNodeUndefinedValue, 200.0);
                    }],
                    [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                        n.view = cellView.descriptionTextField,
                        n.measure = ^CGSize(CGFloat width) {
                            if (isnan(width)) { return CGSizeZero; }
                            return [weakCellView.descriptionTextField sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)];
                        };
                    }],
                ];
            }]

        ];
    }];

    return [parent buildLayout];
}


#pragma mark - NSTableViewDataSource, NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.listOfMovies.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *MyIdentifier = @"MovieListTableViewCellView";
    MovieListTableViewCellView *cellView = [tableView makeViewWithIdentifier:MyIdentifier owner:self];
    if (cellView == nil) {
        cellView = [[MovieListTableViewCellView alloc] initWithFrame:CGRectZero];
        cellView.identifier = MyIdentifier;
    }
    [self configureCellView:cellView row:row];
    return cellView;
    
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    [self.cellViewForRowHeightCalculation viewDidMoveToSuperview];
    [self configureCellView:self.cellViewForRowHeightCalculation row:row];
    
    NSRect r = self.cellViewForRowHeightCalculation.frame;
    r.size.width = CGRectGetWidth(self.tableView.bounds);
    self.cellViewForRowHeightCalculation.frame = r;
    
    return self.cellViewForRowHeightCalculation.rowHeight;
}

@end
