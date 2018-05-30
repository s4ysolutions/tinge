//
//  DropboxUploadStorage.m
//  Tinge
//
//  Created by Sergey Dolin on 8/19/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "DropboxUploadStorage.h"
#import "OAuthStorage.h"
#import "OAuth2WindowController.h"
#import "NSData+Base64.h"


@implementation DropboxUploadStorage {
    @private
    NSURL* _fileURL;
}

+(DropboxUploadStorage*) storageWithFileURL:(NSURL*)file{
    return [[[DropboxUploadStorage alloc] initWithFileURL:file] autorelease];
};

+(void)initDefaults{
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES],@"dp_direct_link",
                                 nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
};
+(void)toggleDirectLink{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:!DropboxUploadStorage.directLink] forKey:@"dp_direct_link"];

};
+(BOOL)directLink{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL dr=[prefs boolForKey:@"dp_direct_link"];
    return dr;
};

-(id)initWithFileURL:(NSURL*)fileURL{
    self=[super init];
    if (self!=nil){
        _fileURL=[fileURL retain];
    }
    return self;
}

-(void)dealloc{
    [_fileURL release];
    [super dealloc];
}

- (NSString*)provider{
    return @"dropbox";
}

- (NSString*)stringAccessToken{
    return [OAuthStorage accessTokenOfProvider:[self provider]];
}

-(BOOL)isAllowed{
//  return NO;
    return [self stringAccessToken]!=nil && [OAuthStorage isAccessTokenValid:[self provider]] ;
}

-(void) setValid:(BOOL)valid{
    [OAuthStorage setAccessTokenValid:valid forProvider:[self provider]] ;
}

-(void) allowSuccess:(BOOL*)success userCancel:(BOOL*)cancel{
    [OAuth2WindowController authWithUploadStorage:self success:success userCancel:cancel];
}

-(NSString*) imageName{
    return @"dropbox";
};

-(NSString*) textNone{
    return @"Dropbox upload will start soon...";
};

-(NSString*) textConnecting{
    return @"Trying to contact Dropbox";
};

-(NSString*) textUploadInProgress{
    return @"Image is uploading to Dropbox...";
};

-(NSString*) textUploadSuccess{
    return @"Image has been uploaded to Dropbox";
};

-(NSString*) textUploadFailed{
    return @"Dropbox error: %@";
};

-(NSString*) textLinkInProgress{
    return @"Getting a link of the image...";
};

-(NSString*) textLinkSuccess{
    return @"Link of the uploaded image has been pasted to the clipboard";
};

-(NSString*) textLinkFailed{
    return @"Dropbox error: %@";
};

-(NSURL*) urlOAuth2Code{
    return [NSURL URLWithString: @"https://www.dropbox.com/1/oauth2/authorize?response_type=code&client_id=ca0vv8n1ob0gsgu"];
};


-(NSMutableURLRequest*)requestOAuth2TokenForCode:(NSString*)code{
//    NSString *url=[NSString stringWithFormat: @"https://api.dropboxapi.com/1/oauth2/token?code=%@&grant_type=authorization_code&client_id=ca0vv8n1ob0gsgu",code];
    NSString *url=[NSString stringWithFormat: @"https://api.dropboxapi.com/1/oauth2/token?code=%@&grant_type=authorization_code",code];
   // NSString *url=@"https://api.dropboxapi.com/1/oauth2/token";
    
    NSString *auth=[[@"ca0vv8n1ob0gsgu" stringByAppendingString:@":"] stringByAppendingString:@"qbyylqqpyutbh0o"];
    NSString *auth64=[[auth dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLCacheStorageNotAllowed
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  //  [request setValue:code forHTTPHeaderField:@"code"];
   // [request setValue:@"authorization_code" forHTTPHeaderField:@"grant_type"];
    [request setValue:[NSString stringWithFormat:@"Basic %@",auth64] forHTTPHeaderField:@"Authorization"];
    return request;
};


-(NSMutableURLRequest*) requestUpload{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: @"https://content.dropboxapi.com/2/files/upload"]
     cachePolicy:NSURLCacheStorageNotAllowed
     timeoutInterval:60.0];
    
    NSString* accessToken =[self stringAccessToken];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:[NSString stringWithFormat:@"{\"path\": \"/Tinge/%@\",\"mode\": \"add\",\"autorename\": true,\"mute\": true}",[[_fileURL pathComponents] lastObject]] forHTTPHeaderField:@"Dropbox-API-Arg"];
    return request;
};

-(NSMutableURLRequest*) requestLink{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: @"https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings"]
                                                           cachePolicy:NSURLCacheStorageNotAllowed
                                                       timeoutInterval:20.0];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",[self stringAccessToken]] forHTTPHeaderField:@"Authorization"];
    NSString *json=[NSString stringWithFormat:@"{\"path\": \"/Tinge/%@\",\"settings\": {\"requested_visibility\": \"public\"}}",[[_fileURL pathComponents] lastObject]];
    NSData *requestData = [NSData dataWithBytes:[json UTF8String] length:[json length]];

    [request setHTTPBody: requestData];
    return request;
};

-(NSString*) responeLinkFromResponse:(NSData*) response {
    if (nil==response)
        return @"Empty response";
    
    NSString *s=[[NSString alloc] initWithData:response
                                             encoding:NSUTF8StringEncoding];

    if (nil==s)
        return @" Empty response";

    NSRange r=[s rangeOfString:@"\"http"];
    if (r.location==NSNotFound)
        return @"No URL";
    s=[s substringFromIndex:r.location+1];
    r=[s rangeOfString:@"\""];
    if (r.location==NSNotFound)
        return @"URL malformed";
    s=[s substringToIndex:r.location];
    if ([DropboxUploadStorage directLink]){
        r=[s rangeOfString:@"www.dropbox."];
        if (r.location!=NSNotFound){
            s=[s stringByReplacingOccurrencesOfString:@"www.dropbox." withString:@"dl.dropboxusercontent."];
            r=[s rangeOfString:@"?"];
            if (r.location!=NSNotFound){
                s=[s substringToIndex:r.location];
            }
        }else{
            NSLog(@"Can't get direct Dropbox link from %@",s);
        }
    }
    return s;
}

//leading space == error
-(NSString*) accessTokenFromResponse:(NSData*) response {
    if (nil==response)
        return @" Empty response";
    
    NSString *s=[[NSString alloc] initWithData:response
                                      encoding:NSUTF8StringEncoding];
    if (nil==s)
        return @" Empty response";

    NSRange r=[s rangeOfString:@"\"access_token\": \""];
    if (r.location==NSNotFound)
               return [@" No Access token found in: " stringByAppendingString: s];
    NSString* ns=[s substringFromIndex:r.location+r.length];
    r=[ns rangeOfString:@"\""];
    if (r.location==NSNotFound)
        return [@" Access token malformed in: "  stringByAppendingString: s];
    return[ns substringToIndex:r.location];
};

@end
