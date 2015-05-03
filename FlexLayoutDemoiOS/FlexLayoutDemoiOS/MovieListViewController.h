//
//  ViewController.h
//  FlexLayoutDemoiOS
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MovieListViewControllerCellLayoutRow,
    MovieListViewControllerCellLayoutColumn,
    MovieListViewControllerCellLayoutColumnSubclass,
} MovieListViewControllerCellLayout;

@interface MovieListViewController : UIViewController
- (instancetype)initWithCellLayout:(MovieListViewControllerCellLayout)layout;
@end

