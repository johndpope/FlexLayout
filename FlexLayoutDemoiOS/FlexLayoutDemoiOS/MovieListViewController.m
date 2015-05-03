//
//  MovieListViewController.m
//  FlexLayoutDemoiOS
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import "MovieListViewController.h"
#import <FlexLayout/FlexLayout.h>

#import "MovieModel.h"


#pragma mark - MovieListTableViewCell

@interface MovieListTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIImageView *posterImageView;

@property (assign, nonatomic, getter=isTemporary) BOOL temporary;

@property (copy, nonatomic) MovieModel *movieModel;
@property (strong, nonatomic) FLTLayout *layout;
@end


@implementation MovieListTableViewCell

#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self == nil) { return self; }
    [self initCell];
    return self;
}

- (void)initCell
{
    _temporary = NO;
    
    _titleLabel = ({
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:15.0];
        [self.contentView addSubview:label];
        label;
    });
    
    _descriptionLabel = ({
        UILabel *label = [UILabel new];
        label.numberOfLines = 3;
        label.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:label];
        label;
    });
    
    _posterImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:imageView];
        imageView;
    });
}


#pragma mark - UITableViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.movieModel cancelFetchPoster];

    self.titleLabel.text = nil;
    self.descriptionLabel.text = nil;
    self.posterImageView.image = nil;
}


#pragma mark - Getter and Setter

- (void)setMovieModel:(MovieModel *)movieModel
{
    _movieModel = movieModel;
 
    self.titleLabel.text = movieModel.title;
    self.descriptionLabel.text = movieModel.plot;
    
    [self loadImage];
}


#pragma mark - Layout 

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isTemporary) { return; }
    
    [self.layout layoutForSize:self.contentView.bounds.size];
    [self.layout layoutViews];
    
}

- (CGFloat)rowHeight
{
    [self.layout layoutForSize:CGSizeMake(self.contentView.bounds.size.width, FLTNodeUndefinedValue)];
    return CGRectGetHeight(self.layout.frame);
}


#pragma mark - Fetch image

- (void)loadImage
{
    if (self.isTemporary) { return; }
    
    [self.movieModel fetchPoster:^(UIImage *image) {
        self.posterImageView.image = image;
        [self setNeedsDisplay];
    }];
}

@end


#pragma mark - MovieListTableViewCellInSubclass

// The layout is directly baked into the table view cell
@interface MovieListTableViewCellInSubclass : MovieListTableViewCell

@end

@implementation MovieListTableViewCellInSubclass

- (FLTLayout *)layout
{
    FLTLayout *layout = [super layout];
    if (layout != nil) {
        return layout;
    }
 
    // Use weak to prevent retainCycle in measure block
    __weak MovieListTableViewCellInSubclass *weakSelf = self;
    
    FLTNode *parent = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.view = self.contentView;
        n.direction = FLTNodeDirectionColumn;
        n.padding = FLTEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        n.children = @[
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = self.titleLabel,
                n.measure = ^CGSize(CGFloat width) {
                    if (isnan(width)) { return CGSizeZero; }
                    return [weakSelf.titleLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
                };
            }],
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = self.posterImageView,
                n.margin = FLTEdgeInsetsMake(10, 0, 0, 0);
                n.size = CGSizeMake(FLTNodeUndefinedValue, 300.0);
            }],
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = self.descriptionLabel,
                n.margin = FLTEdgeInsetsMake(10, 10, 10, 10);
                n.measure = ^CGSize(CGFloat width) {
                    if (isnan(width)) { return CGSizeZero; }
                    return [weakSelf.descriptionLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
                };
            }],

        ];
    }];

    layout = [parent buildLayout];
    self.layout = layout;
    return layout;
}

@end


#pragma mark - MovieListViewController

static NSString *MyReuseIdentifier = @"MyReuseIdentifier";

@interface MovieListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) MovieListViewControllerCellLayout cellLayout;
@property (copy, nonatomic) NSArray *listOfMovies;
@property (strong, nonatomic) MovieListTableViewCell *cellForRowHeightCalculation;
@end

@implementation MovieListViewController


#pragma mark - Lifecycle

- (instancetype)initWithCellLayout:(MovieListViewControllerCellLayout)layout
{
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) { return self; }
    _cellLayout = layout;
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"List of Movies";
    
    [self loadData];
    
    Class cellClass = self.cellLayout == MovieListViewControllerCellLayoutColumnSubclass ? MovieListTableViewCellInSubclass.class
                                                                  : MovieListTableViewCell.class;
    self.cellForRowHeightCalculation = ({
        MovieListTableViewCell *cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.temporary = YES;
        cell;
    });
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [tableView registerClass:cellClass forCellReuseIdentifier:MyReuseIdentifier];
        [self.view addSubview:tableView];
        tableView;
    });
}

- (void)loadData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *moviesList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSMutableArray *dataArray = [NSMutableArray array];
    [moviesList enumerateObjectsUsingBlock:^(NSDictionary *movieDictionary, NSUInteger idx, BOOL *stop) {
        MovieModel *movie = [MovieModel movieWithDictionary:movieDictionary];
        [dataArray addObject:movie];
    }];
    self.listOfMovies = dataArray;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listOfMovies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MovieListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyReuseIdentifier forIndexPath:indexPath];
    [self configureTableViewCell:cell indexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureTableViewCell:self.cellForRowHeightCalculation indexPath:indexPath];

    CGRect frame = self.cellForRowHeightCalculation.frame;
    frame.size.width = CGRectGetWidth(tableView.frame);
    self.cellForRowHeightCalculation.frame = frame;
    
    return self.cellForRowHeightCalculation.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Layouts

// Configure and carete layout if necessary
- (void)configureTableViewCell:(MovieListTableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    cell.movieModel = self.listOfMovies[indexPath.row];

    // If we use cell's where the layout is backed into the subclass don't assign a layout to that
    if (self.cellLayout == MovieListViewControllerCellLayoutColumnSubclass) { return; }
    
    // If the cell already has a layout we don't need to assign it again
    if (cell.layout != nil) { return; }
    
    // Assign layout based on current setting
    cell.layout = (self.cellLayout == MovieListViewControllerCellLayoutColumn) ? [self columnLayoutForCell:cell]
                                                              : [self rowLayoutForCell:cell];
}

- (FLTLayout *)columnLayoutForCell:(MovieListTableViewCell *)cell
{
    // Use weak to prevent retainCycle in measure block
    __weak MovieListTableViewCell *weakCell = cell;
    
    FLTNode *parent = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.view = cell.contentView;
        n.direction = FLTNodeDirectionColumn;
        n.padding = FLTEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        n.children = @[
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = cell.titleLabel,
                n.measure = ^CGSize(CGFloat width) {
                    if (isnan(width)) { return CGSizeZero; }
                    return [weakCell.titleLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
                };
            }],
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = cell.posterImageView,
                n.margin = FLTEdgeInsetsMake(10, 0, 0, 0);
                n.size = CGSizeMake(FLTNodeUndefinedValue, 300.0);
            }],
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = cell.descriptionLabel,
                n.margin = FLTEdgeInsetsMake(10, 10, 10, 10);
                n.measure = ^CGSize(CGFloat width) {
                    if (isnan(width)) { return CGSizeZero; }
                    return [weakCell.descriptionLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
                };
            }],

        ];
    }];
    return [parent buildLayout];
}

- (FLTLayout *)rowLayoutForCell:(MovieListTableViewCell *)cell
{
    // Use weak to prevent retainCycle in measure block    
    __weak MovieListTableViewCell *weakCell = cell;
    
    UIView *titleDescriptionContainer = [UIView new];
    [titleDescriptionContainer addSubview:cell.titleLabel];
    [titleDescriptionContainer addSubview:cell.descriptionLabel];
    [cell.contentView addSubview:titleDescriptionContainer];
    
    // Title and Description will be layed out on the right side besides the image view and will stretch
    FLTNode *titleDescriptionContainerNode = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.view = titleDescriptionContainer;
        n.flex = 1;
        n.direction = FLTNodeDirectionColumn;
        n.padding = FLTEdgeInsetsMake(10, 10, 10, 10);
        n.children = @[
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = cell.titleLabel,
                n.measure = ^CGSize(CGFloat width) {
                    if (isnan(width)) { return CGSizeZero; }
                    return [weakCell.titleLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
                };
            }],
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = cell.descriptionLabel,
                n.margin = FLTEdgeInsetsMake(10, 0, 0, 0);
                n.measure = ^CGSize(CGFloat width) {
                    if (isnan(width)) { return CGSizeZero; }
                    return [weakCell.descriptionLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
                };
            }]
        ];
    }];
    
    // Parent layout
    FLTNode *parent = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.view = cell.contentView;
        n.direction = FLTNodeDirectionRow;
        n.justification = FLTNodeJustificationFlexStart;
        n.childAlignment = FLTNodeChildAlignmentStretch;
        n.children = @[
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = cell.posterImageView,
                n.size = CGSizeMake(100.0, FLTNodeUndefinedValue);
            }],
            titleDescriptionContainerNode
        ];
    }];
    return [parent buildLayout];
}
@end
