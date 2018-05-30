//
//  OAuth2WindowController.h
//  Tinge
//
//  Created by Sergey Dolin on 8/20/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UploadStorage.h"

@interface OAuth2WindowController : NSWindowController<NSURLConnectionDelegate> {

    IBOutlet NSImageView* logo;
    IBOutlet NSTextField* code;
    IBOutlet NSTextField* textError;
    IBOutlet NSProgressIndicator* progress;
}

- (IBAction)selectOpenBrowser:(id)sender;
//- (IBAction)selectDone:(id)sender;
- (IBAction)selectCancel:(id)sender;


//+(void)authWithProvider:(NSString*)provider andImage:(NSString*)image andURL:(NSURL*)url;

+(void)authWithUploadStorage:(NSObject<UploadStorage>*)storage success:(BOOL*)success userCancel:(BOOL*)cancel;
@end
