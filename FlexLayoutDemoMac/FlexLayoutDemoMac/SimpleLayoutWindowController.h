//
//  SimpleLayoutWindowController.h
//  FlexLayoutDemoMac
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FlexLayout/FlexLayout.h>
@interface SimpleLayoutWindowController : NSWindowController {
    FLTLayout *layout;
}
-(void)highlightSubview:(id)sender;
@end
