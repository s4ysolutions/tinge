//
//  UploadModel.h
//  Tinge
//
//  Created by Sergey Dolin on 8/18/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UploadStorage <NSObject>
-(BOOL) isAllowed;
-(void) setValid:(BOOL)valid;
-(void) allowSuccess:(BOOL*)success userCancel:(BOOL*)cancel;
-(NSString*) provider;
-(NSString*) imageName;
-(NSString*) textNone;
-(NSString*) textConnecting;
-(NSString*) textUploadInProgress;
-(NSString*) textUploadSuccess;
-(NSString*) textUploadFailed;
-(NSString*) textLinkInProgress;
-(NSString*) textLinkSuccess;
-(NSString*) textLinkFailed;
-(NSMutableURLRequest*) requestUpload;
-(NSMutableURLRequest*) requestLink;
-(NSURL*) urlOAuth2Code;
-(NSMutableURLRequest*)requestOAuth2TokenForCode:(NSString*)code;
-(NSString*) accessTokenFromResponse:(NSData*) response;
-(NSString*) responeLinkFromResponse:(NSData*) response;
@end
