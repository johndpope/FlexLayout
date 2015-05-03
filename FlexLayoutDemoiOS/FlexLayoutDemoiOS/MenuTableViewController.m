//
//  MenuTableViewController.m
//  FlexLayoutDemoiOS
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import "MenuTableViewController.h"
#import "MovieListViewController.h"

static NSString *CellIdentifier = @"Cell";

@interface MenuTableViewController ()
@property (copy, nonatomic) NSArray *menuItems;
@end

@implementation MenuTableViewController


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Menu";
    self.menuItems = @[
        @"Row Style Layout",
        @"Column Style Layout",
        @"Column Style Layout in Subclass"
    ];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CellIdentifier];
}


#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.menuItems[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MovieListViewControllerCellLayout cellLayout = (MovieListViewControllerCellLayout)indexPath.row;
    MovieListViewController *viewController = [[MovieListViewController alloc] initWithCellLayout:cellLayout];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
