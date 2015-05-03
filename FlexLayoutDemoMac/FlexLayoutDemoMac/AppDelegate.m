//
//  AppDelegate.m
//  FlexLayoutDemoMac
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import "AppDelegate.h"

#import "MovieListWindowController.h"
#import "SimpleLayoutWindowController.h"
#import "FancierLayoutWindowController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate {
    SimpleLayoutWindowController *_simpleLayoutWindowController;
    FancierLayoutWindowController *_fancierLayoutWindowController;
    MovieListWindowController *movieListWindowController;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)openSimpleLayout:(id)sender
{
    if (_simpleLayoutWindowController == nil) {
        _simpleLayoutWindowController = [[SimpleLayoutWindowController alloc] initWithWindowNibName:@"SimpleLayoutWindowController"];
    }
    
    [_simpleLayoutWindowController showWindow:self];
}

- (IBAction)openFancierLayout:(id)sender
{
    if (_fancierLayoutWindowController == nil) {
        _fancierLayoutWindowController = [[FancierLayoutWindowController alloc] initWithWindowNibName:@"FancierLayoutWindowController"];
    }

    [_fancierLayoutWindowController showWindow:self];
}

- (IBAction)openLayoutInTableView:(id)sender
{
    if (movieListWindowController == nil) {
        movieListWindowController = [[MovieListWindowController alloc] initWithWindowNibName:@"MovieListWindowController"];
    }
    
    [movieListWindowController showWindow:self];
}

@end
