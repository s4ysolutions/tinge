//
//  DropboxUploadStorage.h
//  Tinge
//
//  Created by Sergey Dolin on 8/19/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UploadStorage.h"

@interface DropboxUploadStorage : NSObject<UploadStorage>
+(DropboxUploadStorage*) storageWithFileURL:(NSURL*)file;
+(void)initDefaults;
+(void)toggleDirectLink;
+(BOOL)directLink;
@end
