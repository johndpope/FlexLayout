//
//  FancierLayoutWindowController.m
//  FlexLayoutDemoMac
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import "FancierLayoutWindowController.h"
#import "MISViewWithBackgroundColor.h"
#import <FlexLayout/FlexLayout.h>

@interface FancierLayoutWindowController ()
@property (strong, nonatomic) MISViewWithBackgroundColor *orangeView;
@property (strong, nonatomic) NSTextField *textField;
@property (strong, nonatomic) MISViewWithBackgroundColor *greenView;

@property (strong, nonatomic) FLTLayout *layout;
@end

@implementation FancierLayoutWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSView *contentView = self.window.contentView;
    
    // Setup some subviews
    self.orangeView = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(46, 185, 171, 110)];
    self.orangeView.backgroundColor = [NSColor colorWithDeviceRed:0.972 green:0.587 blue:0.153 alpha:1];
    
    self.greenView = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(63, 60, 135, 83)];
    self.greenView.backgroundColor = [NSColor colorWithDeviceRed:0.168 green:0.988 blue:0.18 alpha:1];
    
    self.textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0.0, 0.0, 0.0, 0.0)];
    self.textField.bezeled = NO;
    self.textField.backgroundColor = [NSColor clearColor];
    self.textField.stringValue = @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
    
    
    [contentView addSubview:self.orangeView];
    [contentView addSubview:self.textField];
    [contentView addSubview:self.greenView];
    
    [self buildLayout];
    [self layoutSubviews];
}

- (void)windowDidResize:(NSNotification *)notification
{
    [self layoutSubviews];
}

- (void)buildLayout
{
    // Place blue and yellow view witin the orange view
    MISViewWithBackgroundColor *blueView = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(262, 115, 171, 110)];
    blueView.backgroundColor = [NSColor colorWithDeviceRed:0.241 green:0.587 blue:0.561 alpha:1];
    [self.orangeView addSubview:blueView];
    
    MISViewWithBackgroundColor *yellowView = [[MISViewWithBackgroundColor alloc] initWithFrame:NSMakeRect(262, 115, 171, 110)];
    yellowView.backgroundColor = [NSColor colorWithDeviceRed:0.982 green:0.986 blue:0.269 alpha:1];
    [self.orangeView addSubview:yellowView];
 
    // Place a red view with a couple of subviews within the orange view
    MISViewWithBackgroundColor *redView = [[MISViewWithBackgroundColor alloc] initWithFrame:CGRectZero];
    redView.backgroundColor = [NSColor redColor];
    [self.orangeView addSubview:redView];
    
    MISViewWithBackgroundColor *whiteView = [[MISViewWithBackgroundColor alloc] initWithFrame:CGRectZero];
    whiteView.backgroundColor = [NSColor whiteColor];
    [redView addSubview:whiteView];
    
    MISViewWithBackgroundColor *grayView = [[MISViewWithBackgroundColor alloc] initWithFrame:CGRectZero];
    whiteView.backgroundColor = [NSColor grayColor];
    [redView addSubview:grayView];

    // Layout for red view
    FLTNode *redViewNode = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.view = redView;
        n.flex = 1;
        n.margin = FLTEdgeInsetsMakeUniform(10.0);
        n.justification = FLTNodeJustificationFlexEnd; // Place white at the top
        n.children = @[
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = whiteView;
                n.size = CGSizeMake(FLTNodeUndefinedValue, 20);
            }],
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = grayView;
                n.size = CGSizeMake(FLTNodeUndefinedValue, 20);
            }],
        ];
    }];
    
    // Layout for orange view
    FLTNode *orangeViewNode = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.view = self.orangeView,
        n.flex = 1;
        n.margin = FLTEdgeInsetsMake(0, 10, 0, 10);
        n.size = CGSizeMake(FLTNodeUndefinedValue, 100);
        n.direction = FLTNodeDirectionRow;
        n.children = @[
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = blueView;
                n.size = CGSizeMake(30, FLTNodeUndefinedValue);
            }],
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = yellowView;
                n.size = CGSizeMake(30, FLTNodeUndefinedValue);
            }],
            redViewNode
        ];
    }];
    
    // Create layout for content view
    // Use weak to prevent retainCycle in measure block
    __weak FancierLayoutWindowController *weakSelf = self;
    FLTNode *parent = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.direction = FLTNodeDirectionRow;
        n.justification = FLTNodeJustificationFlexStart;
        n.childAlignment = FLTNodeChildAlignmentStretch;
        n.children = @[
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = self.greenView,
                n.margin = FLTEdgeInsetsMake(0, 10, 0, 10);
                n.size = CGSizeMake(60, FLTNodeUndefinedValue);
            }],
            orangeViewNode,
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.view = self.textField,
                n.flex = 1;
                n.margin = FLTEdgeInsetsMake(0, 10, 0, 10);
                n.measure = ^CGSize(CGFloat width) {
                    return [weakSelf.textField sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)];
                };
            }],
        ];
    }];
    self.layout = [parent buildLayout];
}

- (void)layoutSubviews
{
    NSView *contentView = self.window.contentView;
    
    // Relayout based on content view size
    [self.layout layoutForSize:CGSizeMake(CGRectGetWidth(contentView.frame), FLTNodeUndefinedValue)];
    [self.layout layoutViews];
    
    [contentView setNeedsDisplay:YES];
    
    // Calculate the max height for the layout and increase the size of the window if the
    // layout does not fit within the window
    NSRect windowFrame = self.window.frame;
    if (CGRectGetHeight(windowFrame) - self.titleBarHeight < CGRectGetHeight(self.layout.frame)) {
        windowFrame.size.height = CGRectGetHeight(self.layout.frame) + self.titleBarHeight;
        [self.window setFrame:windowFrame display:YES];
    }
}

- (CGFloat)titleBarHeight
{
    NSRect frame = NSMakeRect (0, 0, 100, 100);
    NSRect contentRect = [NSWindow contentRectForFrameRect:frame styleMask:NSTitledWindowMask];
    return (frame.size.height - contentRect.size.height);
}

@end
