//
//  ViewWithBackgroundColor.h
//  MISBoxLayout2
//
//  Created by Michael Schneider on 4/18/15.
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "SimpleLayoutWindowController.h"

IB_DESIGNABLE
@interface MISViewWithBackgroundColor : NSView{
    NSTrackingArea *trackingArea;
    id navDelegate;
}
@property (nonatomic)    BOOL highlighted;
@property (nonatomic, strong) IBInspectable   NSColor *onBackgroundColor;
@property (strong, nonatomic) IBInspectable NSColor *backgroundColor;
@property (atomic, readwrite) int myTag;
- (id)initWithFrame:(NSRect)frame  navDelegate:(id)delegate;
@end
