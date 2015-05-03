//
//  SimpleLayoutWindowController.m
//  FlexLayoutDemoMac
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import "SimpleLayoutWindowController.h"
#import "MISViewWithBackgroundColor.h"
#import <FlexLayout/FlexLayout.h>

@interface SimpleLayoutWindowController ()

@end

@implementation SimpleLayoutWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSView *contentView = self.window.contentView;
    
    MISViewWithBackgroundColor *orangeView = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(46, 185, 171, 110)];
    orangeView.backgroundColor = [NSColor colorWithDeviceRed:0.972 green:0.587 blue:0.153 alpha:1];
    
    MISViewWithBackgroundColor *blueView = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(262, 115, 171, 110)];
    blueView.backgroundColor = [NSColor colorWithDeviceRed:0.241 green:0.587 blue:0.561 alpha:1];
    
    MISViewWithBackgroundColor *pinkView = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(63, 60, 135, 83)];
    pinkView.backgroundColor = [NSColor colorWithDeviceRed:0.921 green:0.658 blue:0.882 alpha:1];
    
    [contentView addSubview:orangeView];
    [contentView addSubview:blueView];
    [contentView addSubview:pinkView];

    [self layoutSubviews];
}


- (void)windowDidResize:(NSNotification *)notification
{
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    NSView *contentView = [self.window contentView];
    FLTNode *parent = FLTNodeMake(^(FLTNodeBuilder *n) {
        n.size = contentView.frame.size;
        n.direction = FLTNodeDirectionRow;
        n.childAlignment = FLTNodeChildAlignmentCenter;
        n.children = @[
            FLTNodeMake(^(FLTNodeBuilder *n) {
                n.flex = 75;
                n.margin = FLTEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
                n.size = CGSizeMake(0, 100.0);
            }),
            FLTNodeMake(^(FLTNodeBuilder *n) {
                n.flex = 15;
                n.margin = FLTEdgeInsetsMake(0.0, 0.0, 0.0, 10.0);
                n.size = CGSizeMake(0, 50.0);
            }),
            FLTNodeMake(^(FLTNodeBuilder *n) {
                n.flex = 10;
                n.margin = FLTEdgeInsetsMake(0.0, 0.0, 0.0, 10.0);
                n.size = CGSizeMake(0, 180.0);
            })
        ];
    });
    FLTLayout *layout = [parent buildLayout];
    NSLog(@"%@", layout);
    [layout applyToView:contentView];
    
    [contentView setNeedsDisplay:YES];
}

@end
