//
//  ScreenshotWindow.m
//  Tinge
//
//  Created by Sergey Dolin on 8/2/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "ScreenshotWindow.h"
#import "ScreenshotView.h"

@implementation ScreenshotWindow
- (id)initWithCGImage:(CGImageRef)image  andDelegator:(NSObject<ScreenshotDelegator>*)delegator
{
    NSRect screenRect = [[NSScreen mainScreen] frame];
    //screenRect.size.height=screenRect.size.height/4;
    //screenRect.size.width=screenRect.size.width/4;
    
    self = [super initWithContentRect:screenRect
                            styleMask:NSBorderlessWindowMask
                              backing:NSBackingStoreBuffered
                                defer:NO screen:[NSScreen mainScreen]];
    
    if (self) {
        int windowLevel;
        
        CGDisplayCapture( kCGDirectMainDisplay );

        windowLevel = CGShieldingWindowLevel();
        
        
        ScreenshotView *screenshotView=[[ScreenshotView alloc] initWithCGImage:image ];
        [screenshotView setDelegator:delegator];
        
        [self setContentView: screenshotView];
        [self setLevel:windowLevel];
        [self setBackgroundColor:[NSColor redColor]];
        [self makeKeyAndOrderFront:nil];
        [self setDelegate:self];
        [self setReleasedWhenClosed:YES];
     
        [screenshotView release];
    }
    return self;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    // get the pressed key
    if ([event keyCode]==kVK_Escape){
        [self close];
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    CGDisplayRelease(kCGDirectMainDisplay);
}

@end
