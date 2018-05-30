//
//  TAppDelegate.h
//  Tinge
//
//  Created by Sergey Dolin on 6/4/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScreenshotDelegator.h"

@interface TAppDelegate : NSObject <NSApplicationDelegate,ScreenshotDelegator> {
    

    NSStatusItem * _statusItem;
    NSMenu* _statusMenu;
}

@property (assign) IBOutlet NSMenu *statusMenu;

-(void) interrogateHardware;
-(void) disableUI;
-(void) enableUI;
-(int) currentDisplay;

-(IBAction)makeScreenShot:(id)sender;
-(IBAction)toggleDropboxLink:(id)sender;
-(IBAction)toggleRunOnStartup:(id)sender;

@end
