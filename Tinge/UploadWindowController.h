//
//  DropboxWindowController.h
//  Tinge
//
//  Created by Sergey Dolin on 8/18/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UploadStorage.h"
#import <WebKit/WebKit.h>

@interface UploadWindowController : NSWindowController<NSURLConnectionDelegate> {
    IBOutlet NSImageView *image;
    IBOutlet NSTextField *text;
    IBOutlet WebView *webview;
}
-(IBAction)selectCancel:(id)sender;
//+(void)uploadFile:(NSURL*)fileURL withImage:(CGImageRef)image toStorage:(NSObject<UploadStorage>*)storage canceled:(BOOL*)canceled mayNeedRepeat:(BOOL*)repeat;//YES if need repeat
+(BOOL)startUploadFile:(NSURL*)fileURL withImage:(CGImageRef)image toStorage:(NSObject<UploadStorage>*)storage;
- (void)closeOnTimer:(NSTimer *)timer;
@end
