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
#import <QuartzCore/QuartzCore.h>

@interface SimpleLayoutWindowController ()

@end

@implementation SimpleLayoutWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSView *contentView = self.window.contentView;
    
    MISViewWithBackgroundColor *orangeView = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(0, 185, 100, 100) navDelegate:self];
    orangeView.backgroundColor = [NSColor colorWithDeviceRed:0.972 green:0.587 blue:0.153 alpha:1];
    orangeView.onBackgroundColor = [NSColor colorWithDeviceRed:0.972 green:0.587 blue:0.13 alpha:1];
    
    MISViewWithBackgroundColor *blueView = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(262, 115, 100, 100) navDelegate:self];
    blueView.backgroundColor = [NSColor colorWithDeviceRed:0.241 green:0.587 blue:0.561 alpha:1];
    blueView.onBackgroundColor = [NSColor colorWithDeviceRed:0.241 green:0.587 blue:0.561 alpha:1];
    
    MISViewWithBackgroundColor *pinkView = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(63, 60, 100, 100) navDelegate:self];
    pinkView.backgroundColor = [NSColor colorWithDeviceRed:0.921 green:0.658 blue:0.882 alpha:1];
    pinkView.onBackgroundColor = [NSColor colorWithDeviceRed:0.921 green:0.658 blue:0.5 alpha:1];
    
    MISViewWithBackgroundColor *pinkView1 = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(63, 60, 100, 100) navDelegate:self ];
    pinkView1.backgroundColor = [NSColor colorWithDeviceRed:0.921 green:0.658 blue:0.882 alpha:1];
    pinkView1.onBackgroundColor = [NSColor colorWithDeviceRed:0.921 green:0.658 blue:0.3 alpha:1];
    
    MISViewWithBackgroundColor *pinkView2 = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(63, 60, 100, 100) navDelegate:self ];
    pinkView2.backgroundColor = [NSColor colorWithDeviceRed:0.921 green:0.658 blue:0.882 alpha:1];
    pinkView2.onBackgroundColor = [NSColor colorWithDeviceRed:0.921 green:0.658 blue:0.3 alpha:1];
    
    
    MISViewWithBackgroundColor *pinkView3 = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(63, 60, 100, 100) navDelegate:self ];
    pinkView3.backgroundColor = [NSColor colorWithDeviceRed:0.921 green:0.658 blue:0.882 alpha:1];
    pinkView3.onBackgroundColor = [NSColor colorWithDeviceRed:0.921 green:0.658 blue:0.3 alpha:1];
    
    MISViewWithBackgroundColor *pinkView4 = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(63, 60, 100, 100) navDelegate:self ];
    pinkView4.backgroundColor = [NSColor colorWithDeviceRed:0.921 green:0.658 blue:0.882 alpha:1];
    pinkView4.onBackgroundColor = [NSColor colorWithDeviceRed:0.921 green:0.658 blue:0.3 alpha:1];
    
    
    [contentView addSubview:orangeView];
    [contentView addSubview:blueView];
    [contentView addSubview:pinkView];
    [contentView addSubview:pinkView1];
    [contentView addSubview:pinkView2];
    [contentView addSubview:pinkView3];
    [contentView addSubview:pinkView4];
    
    [self layoutSubviews];
}


- (void)windowDidResize:(NSNotification *)notification
{
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    NSView *contentView = [self.window contentView];
    FLTNode *parent = [self  parentLayout];
    layout = [parent buildLayout];
    //  layout.children = [self childrenLayouts];
    NSLog(@"%@", layout);
    [layout applyToView:contentView];
    [contentView setNeedsDisplay:YES];
}

-(void)highlightSubview:(id)sender {
    if (sender ==nil) {
        [self layoutSubviews];
    }
    NSView *contentView = self.window.contentView;
    [[contentView subviews] enumerateObjectsUsingBlock:^(NSView *v, NSUInteger idx0, BOOL *stop) {
        if (v == sender) {
            
            NSView *contentView = [self.window contentView];
            FLTNode *parent = [self selectedLayout:idx0];
            
            
            FLTLayout *layout = [parent buildLayout];
            [layout applyToView:contentView];
            [contentView setNeedsDisplay:YES];
            
            
        }
    }];
}


-(FLTNode*)parentLayout {
    NSView *contentView = [self.window contentView];
    FLTNode *parent = FLTNodeMake(^(FLTNodeBuilder *n) {
        n.size = contentView.frame.size;
        n.direction = FLTNodeDirectionColumn;
        n.childAlignment = FLTNodeChildAlignmentCenter;
        n.children =[self childrenLayouts];
    });
    
    
    return parent;
    
}
-(NSArray*)childrenLayouts {
    
    float height=44;
    float width=200;
    return @[
             FLTNodeMake(^(FLTNodeBuilder *n) {
                 n.flex = 5;
                 n.margin = FLTEdgeInsetsMake(0.0, 0.0, 10.0, 10.0);
                 n.size = CGSizeMake(width, height);
             }),
             FLTNodeMake(^(FLTNodeBuilder *n) {
                 n.flex = 15;
                 n.margin = FLTEdgeInsetsMake(0.0, 0.0, 10.0, 10.0);
                 n.size = CGSizeMake(width, height);
             }),
             FLTNodeMake(^(FLTNodeBuilder *n) {
                 n.flex = 15;
                 n.margin = FLTEdgeInsetsMake(0.0, 0.0, 10.0, 10.0);
                 n.size = CGSizeMake(width, height);
                 n.wrap = YES;
             }),
             FLTNodeMake(^(FLTNodeBuilder *n) {
                 n.flex = 35;
                 n.margin = FLTEdgeInsetsMake(0.0, 0.0, 10.0, 10.0);
                 n.size = CGSizeMake(width, height);
             }),
             FLTNodeMake(^(FLTNodeBuilder *n) {
                 n.flex = 25;
                 n.margin = FLTEdgeInsetsMake(0.0, 0.0, 10.0, 10.0);
                 n.size = CGSizeMake(width, height);
             }),
             FLTNodeMake(^(FLTNodeBuilder *n) {
                 n.flex = 15;
                 n.margin = FLTEdgeInsetsMake(0.0, 0.0, 10.0, 10.0);
                 n.size = CGSizeMake(width, height);
             }),
             FLTNodeMake(^(FLTNodeBuilder *n) {
                 n.flex = 5;
                 n.margin = FLTEdgeInsetsMake(0.0, 0.0, 10.0, 10.0);
                 n.size = CGSizeMake(width, height);
             })
             ];
}

-(FLTNode*)selectedLayout:(NSUInteger)selectedIdx {
    NSLog(@"idx:%d",(int)selectedIdx);
    NSView *contentView = [self.window contentView];
    float height=200;
    FLTNode *parent = FLTNodeMake(^(FLTNodeBuilder *n) {
        n.size = contentView.frame.size;
        n.direction = FLTNodeDirectionColumn;
        n.childAlignment = FLTNodeChildAlignmentCenter;
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[self childrenLayouts]];
        [[arr copy] enumerateObjectsUsingBlock:^(FLTNode *n, NSUInteger idx, BOOL *stop) {
            if (selectedIdx == idx) {
                FLTNode *node =  FLTNodeMake(^(FLTNodeBuilder *n1) {
                    n1.flex = 85;
                    n1.margin = FLTEdgeInsetsMake(0.0, 0.0, 10.0, 10.0);
                    n1.size = CGSizeMake(height, height);
                });
                [arr replaceObjectAtIndex:idx withObject:node];
                
            }
        }];
        [arr enumerateObjectsUsingBlock:^(FLTNode *n, NSUInteger idx, BOOL *stop) {
            NSLog(@"flex:%f",n.flex);
        }];
        n.children = arr;
    });
    
    return parent;
    
}

@end
