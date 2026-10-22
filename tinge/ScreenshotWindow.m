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
- (id)initWithCGImage:(CGImageRef)image  display:(CGDirectDisplayID)display andDelegator:(NSObject<ScreenshotDelegator>*)delegator
{
    NSScreen *screen = [NSScreen mainScreen];
    for (NSScreen *candidate in [NSScreen screens]) {
        NSNumber *number = [[candidate deviceDescription] objectForKey:@"NSScreenNumber"];
        if ([number unsignedIntValue] == display) {
            screen = candidate;
        }
    }
    NSRect screenRect = [screen frame];
    //screenRect.size.height=screenRect.size.height/4;
    //screenRect.size.width=screenRect.size.width/4;
    
    self = [super initWithContentRect:screenRect
                            styleMask:NSBorderlessWindowMask
                              backing:NSBackingStoreBuffered
                                defer:NO screen:screen];
    
    if (self) {
        int windowLevel;
        
        CGDisplayCapture( display );

        windowLevel = CGShieldingWindowLevel();
        
        
        ScreenshotView *screenshotView=[[ScreenshotView alloc] initWithCGImage:image display:display];
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
