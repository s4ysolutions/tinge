//
//  PresentationManager.m
//  Tinge
//
//  Created by Sergey Dolin on 8/7/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "PresentationManager.h"

@implementation PresentationManager
+ (void)toForeground {
    
    // Finder to foreground
    if ([[NSApplication sharedApplication] isActive]) {
        for (NSRunningApplication * app in [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.finder"]) {
            [app activateWithOptions:NSApplicationActivateIgnoringOtherApps];
            break;
        }        
    }
    [self performSelector:@selector(transformStep2) withObject:nil afterDelay:0.1];
}

+ (void)transformStep2
{
    // show dock
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    (void) TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    
    [self performSelector:@selector(transformStep3) withObject:nil afterDelay:0.1];
}

+ (void)transformStep3
{
    // move itself in front
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

+ (void)toBackground {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToUIElementApplication);
}

static int sEditors=0;

+ (void)editorDidClose{
    sEditors--;
    if (0==sEditors){
        [PresentationManager toBackground];
    };

};

+ (void)editorDidOpen{
    if (0==sEditors){
        [PresentationManager toForeground];
    };
    sEditors++;
};

+ (void)uploadDidOpen{
    [self editorDidOpen];
};

+ (void)uploadDidClose{
    [self editorDidClose];
};

@end
