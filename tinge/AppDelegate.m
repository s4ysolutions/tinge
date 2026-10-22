//
//  AppDelegate.m
//  tinge
//
//  Created by  Sergey Dolin on 07/10/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

#import "AppDelegate.h"
#import "MASShortcut.h"
#import "MASShortcutMonitor.h"
#import "ScreenshotWindow.h"
//#import "PresentationManager.h"
//#import "ToolPaletteWindowController.h"
#import "EditorWindowController.h"
#import "DropboxUploadStorage.h"

static void DisplayRegisterReconfigurationCallback (CGDirectDisplayID display, CGDisplayChangeSummaryFlags flags, void *userInfo)
{
    AppDelegate * snapshotDelegateObject = (AppDelegate*)userInfo;
    static BOOL DisplayConfigurationChanged = NO;
    
    if(flags == kCGDisplayBeginConfigurationFlag)
    {
        if(DisplayConfigurationChanged == NO)
        {
            [snapshotDelegateObject disableUI];
            DisplayConfigurationChanged = YES;
        }
    }
    else if(DisplayConfigurationChanged == YES)
    {
        [snapshotDelegateObject enableUI];
        [snapshotDelegateObject interrogateHardware];
        DisplayConfigurationChanged = NO;
    }
}

@implementation AppDelegate {
@private
    CGDisplayCount _displaysCount;
    CGDirectDisplayID* _displays;
    BOOL     _displayRegistrationCallBackSuccessful;
    NSWindow *_screenshotWindow;
//    NSDocumentController *_documentController;
}

@synthesize statusMenu = _statusMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //_documentController = [[NSDocumentController sharedDocumentController] retain];
    
    _displaysCount = 0;
    _displays = nil;
    [self interrogateHardware];
    
    _displayRegistrationCallBackSuccessful = NO; // Hasn't been tried yet.
    CGError err = CGDisplayRegisterReconfigurationCallback(DisplayRegisterReconfigurationCallback,self);
    if(err == kCGErrorSuccess)
    {
        _displayRegistrationCallBackSuccessful = YES;
    }
    
    [DropboxUploadStorage initDefaults];
  
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL dr=[prefs boolForKey:@"not_first"];
    if (!dr)
    {
        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"not_first"];
        [self setRunOnLaunch:YES];
    }
    
}

- (void) awakeFromNib {
    [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithBool:NO],@"runOnLaunch",
      [NSNumber numberWithInt:1],@"showMenu",
      nil]];
    //if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"showMenu"] intValue]==1){
        _statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:16] retain];
        [_statusItem setMenu:_statusMenu];
    NSImage *menuImage = [NSImage imageNamed:@"tingeMenu"];
    /* template image: the menu bar tints it for light/dark mode like other items */
    [menuImage setTemplate:YES];
    [_statusItem setImage: menuImage];//[[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"tingeMenu" ofType:@"png"]] autorelease]];
        [_statusItem setHighlightMode:YES];
//        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    /*}else{
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    }*/
    
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_2 modifierFlags:NSCommandKeyMask | NSShiftKeyMask];
    [[MASShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
        [self makeScreenShot:self];
        //        [[NSSound soundNamed:@"Hero"] play];
    }];
}

-(void) dealloc
{
    
     // CGDisplayRemoveReconfigurationCallback Removes the registration of a callback function that’s invoked
     // whenever a local display is reconfigured.  We only remove the registration if it was successful in the first place.
     if(CGDisplayRemoveReconfigurationCallback != NULL && _displayRegistrationCallBackSuccessful == YES)
     {
         CGDisplayRemoveReconfigurationCallback(DisplayRegisterReconfigurationCallback, self);
     }
    
    //    [captureMenuItem release];
    
    if(_displays != nil)
    {
        free(_displays);
    }
//    [_documentController release];
    [super dealloc];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

#pragma mark *** Displays ***
-(void)interrogateHardware
{
    CGError                err = CGDisplayNoErr;
    CGDisplayCount        dspCount = 0;
    
    err = CGGetActiveDisplayList(0, NULL, &dspCount);
    if(err != CGDisplayNoErr)
    {
        return;
    }
    if(_displays != nil)
    {
        free(_displays);
    }
    
    _displaysCount=dspCount;
    _displays = calloc((size_t)dspCount, sizeof(CGDirectDisplayID));
    
    err = CGGetActiveDisplayList(dspCount,
                                 _displays,
                                 &dspCount);
    
    /* More error-checking here. */
    if(err != CGDisplayNoErr)
    {
        // TODO: report?
        NSLog(@"Could not get active display list (%d)\n", err);
        return;
    }
    
}

-(void) disableUI
{
    //   [captureMenuItem setEnabled:NO];
}

-(void) enableUI
{
    //   [captureMenuItem setEnabled:YES];
}

-(int) currentDisplay
{
    return 0;
}

#pragma mark *** Screenshotting ***
- (IBAction)makeScreenShot:(id)sender {
    if (_displaysCount==0)
        return;
    CGDirectDisplayID display = _displays[[self currentDisplay]];
    CGImageRef image = CGDisplayCreateImage(display);
    if (image)
    {
        _screenshotWindow=[[ScreenshotWindow alloc] initWithCGImage:image display:display andDelegator:self];
        CGImageRelease(image);
        [[NSSound soundNamed:@"Hero"] play];
    }else{
        //TODO:
    }
}

- (void)screenshot:(CGImageRef)screenshot wasCropped:(CGImageRef) cropped{
    [_screenshotWindow close];
    [EditorWindowController startEdit:cropped];
    /*
    EditorWindowController* ewc=[[EditorWindowController alloc ] initWithImageRef:cropped];
    if (ewc){
        [ewc showWindow:self];
    }*/
    //if (newDocument)
    /*
    if (ewc)
    {
        //[newDocument setCGImage:cropped];
        //[PresentationManager documentWasCreated];
        //[ToolPaletteWindowController show];
        _editorWindowControllers app
    }*/
};

-(IBAction)toggleDropboxLink:(id)sender{
    [DropboxUploadStorage toggleDirectLink];
};

-(IBAction)toggleRunOnStartup:(id)sender{
    [self setRunOnLaunch:![self runOnLaunch]];
};


- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
    if ([item action]==@selector(toggleDropboxLink:)) {
        if ([DropboxUploadStorage directLink])
            [(NSMenuItem*)item setState:NSOnState];
        else
            [(NSMenuItem*)item setState:NSOffState];
        return YES;
    }else if ([item action]==@selector(toggleRunOnStartup:)) {
        if ([self runOnLaunch])
            [(NSMenuItem*)item setState:NSOnState];
        else
            [(NSMenuItem*)item setState:NSOffState];
        return YES;
    }
    return YES;
//    return [super validateUserInterfaceItem:item];
}
#pragma mark *** Run on Startup

-(void)setRunOnLaunch:(BOOL)runOnLaunch{
    LSSharedFileListRef loginsList;
    LSSharedFileListItemRef itemRef;
    
    BOOL exists=[self findLaunchItem:&itemRef inLoginsList:&loginsList];
    
    if (runOnLaunch && !exists){
        CFURLRef path = (CFURLRef)[[NSRunningApplication currentApplication] bundleURL];
        BOOL exist=[self runOnLaunch];
        if (exist) return;
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginsList, kLSSharedFileListItemLast, NULL, NULL, path, NULL, NULL);
        if (item)
            CFRelease(item);
    }else if (!runOnLaunch && exists){
        LSSharedFileListItemRemove(loginsList, itemRef);
    }
    
    if (exists){
        CFRelease(itemRef);
    }
}

-(BOOL) findLaunchItem:(LSSharedFileListItemRef*)pItemRef inLoginsList:(LSSharedFileListRef*)pLoginsList{
    NSURL * appPath=[[NSRunningApplication currentApplication] bundleURL];
    UInt32 seedValue;
    *pLoginsList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(*pLoginsList, &seedValue);
    for (id item in loginItemsArray) {
        *pItemRef = (LSSharedFileListItemRef)item;
        NSURL* path;
        if (LSSharedFileListItemResolve(*pItemRef, 0, (CFURLRef*) &path, NULL) == noErr) {
            if ([path isEqual:appPath]) {
                CFRetain(*pItemRef);
                CFRelease(loginItemsArray);
                return YES;
            }
        }
    };
    CFRelease(loginItemsArray);
    return NO;
}

-(BOOL)runOnLaunch{
    LSSharedFileListRef loginsList;
    LSSharedFileListItemRef itemRef;
    
    return [self findLaunchItem:&itemRef inLoginsList:&loginsList];
}

@end
