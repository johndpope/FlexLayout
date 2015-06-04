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
    
    [contentView addSubview:orangeView];
    [contentView addSubview:blueView];
    [contentView addSubview:pinkView];
    [contentView addSubview:pinkView1];

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
    FLTLayout *layout = [parent buildLayout];
    NSLog(@"%@", layout);
    [layout applyToView:contentView];
    [contentView setNeedsDisplay:YES];
}

-(void)highlightSubview:(id)sender{
    if (sender ==nil){
        [self layoutSubviews];
    }
   NSView *contentView = self.window.contentView;
    [[contentView subviews] enumerateObjectsUsingBlock:^(NSView *v, NSUInteger idx, BOOL *stop) {
        if (v == sender) {
           [CATransaction setAnimationDuration:10];
           [CATransaction begin];
           [CATransaction setCompletionBlock:^{
                    NSLog(@"setCompletionBlock");
          }];
            NSView *contentView = [self.window contentView];
            FLTNode *parent = [self selectedLayout:idx];
            FLTLayout *layout = [parent buildLayout];
            [layout applyToView:contentView];
            [contentView setNeedsDisplay:YES];
            [CATransaction commit];
        }
    }];
}


-(FLTNode*)parentLayout{
    NSView *contentView = [self.window contentView];
    FLTNode *parent = FLTNodeMake(^(FLTNodeBuilder *n) {
        n.size = contentView.frame.size;
        n.direction = FLTNodeDirectionRow;
        n.childAlignment = FLTNodeChildAlignmentCenter;
        n.children =[self childrenLayouts];
    });

    return parent;

}
-(NSArray*)childrenLayouts{
    
    NSView *contentView = [self.window contentView];
    float height=contentView.visibleRect.size.height;
    return @[
      FLTNodeMake(^(FLTNodeBuilder *n) {
          n.flex = 25;
          n.margin = FLTEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
          n.size = CGSizeMake(0, height);
      }),
      FLTNodeMake(^(FLTNodeBuilder *n) {
          n.flex = 25;
          n.margin = FLTEdgeInsetsMake(0.0, 0.0, 0.0, 10.0);
          n.size = CGSizeMake(0, height);
      }),
      FLTNodeMake(^(FLTNodeBuilder *n) {
          n.flex = 25;
          n.margin = FLTEdgeInsetsMake(0.0, 0.0, 0.0, 10.0);
          n.size = CGSizeMake(0, height);
      }),
      FLTNodeMake(^(FLTNodeBuilder *n) {
          n.flex = 25;
          n.margin = FLTEdgeInsetsMake(0.0, 0.0, 0.0, 10.0);
          n.size = CGSizeMake(0, height);
      })
      ];
}

-(FLTNode*)selectedLayout:(NSUInteger)selectedIdx{
    NSLog(@"idx:%d",(int)selectedIdx);
    NSView *contentView = [self.window contentView];
        float height=contentView.visibleRect.size.height;
    FLTNode *parent = FLTNodeMake(^(FLTNodeBuilder *n) {
        n.size = contentView.frame.size;
        n.direction = FLTNodeDirectionRow;
        n.childAlignment = FLTNodeChildAlignmentCenter;
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[self childrenLayouts]];
        [[arr copy] enumerateObjectsUsingBlock:^(FLTNode *n, NSUInteger idx, BOOL *stop) {
            if (selectedIdx == idx) {
              FLTNode *node =  FLTNodeMake(^(FLTNodeBuilder *n1) {
                    n1.flex = 35;
                    n1.margin = FLTEdgeInsetsMake(0.0, 0.0, 0.0, 10.0);
                    n1.size = CGSizeMake(0, height);
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
