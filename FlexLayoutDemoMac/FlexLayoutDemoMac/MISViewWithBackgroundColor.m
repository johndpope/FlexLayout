//
//  ViewWithBackgroundColor.m
//  MISBoxLayout2
//
//  Created by Michael Schneider on 4/18/15.
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import "MISViewWithBackgroundColor.h"

@implementation MISViewWithBackgroundColor

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, NSRectToCGRect(dirtyRect));

    [super drawRect:dirtyRect];
}

@end
