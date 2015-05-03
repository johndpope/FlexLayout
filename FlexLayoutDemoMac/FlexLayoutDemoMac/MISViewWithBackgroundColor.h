//
//  ViewWithBackgroundColor.h
//  MISBoxLayout2
//
//  Created by Michael Schneider on 4/18/15.
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <AppKit/AppKit.h>

IB_DESIGNABLE
@interface MISViewWithBackgroundColor : NSView
@property (strong, nonatomic) IBInspectable NSColor *backgroundColor;
@end
