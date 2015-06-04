//
//  ViewWithBackgroundColor.m
//  MISBoxLayout2
//
//  Created by Michael Schneider on 4/18/15.
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import "MISViewWithBackgroundColor.h"

@implementation MISViewWithBackgroundColor

- (id)initWithFrame:(NSRect)frame  navDelegate:(id)delegate{
   
    self = [super initWithFrame:frame];
    

    if (self) {
           navDelegate = delegate;
        
            int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways|NSTrackingInVisibleRect);
            trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                                    options:opts
                                                                      owner:self
                                                                   userInfo:nil];

            [self addTrackingArea:trackingArea];

    }
    return self;
}




- (void)dealloc {
  //  [self removeTrackingRect:trackingArea];
}
- (void)mouseExited:(NSEvent *)theEvent{
    self.highlighted = NO;
    [self setNeedsDisplay:YES];
    [(SimpleLayoutWindowController*)navDelegate highlightSubview:nil];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    NSLog(@"entered");
     self.highlighted = YES;
    [self setNeedsDisplay:YES];
    [(SimpleLayoutWindowController*)navDelegate highlightSubview:self];
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
        if (self.highlighted) {
            [self.onBackgroundColor set];
        }
        else {
            [self.backgroundColor set];
        }
        NSRectFill(dirtyRect);

}

@end
