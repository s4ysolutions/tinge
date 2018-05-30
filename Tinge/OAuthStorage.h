//
//  OAuthStorage.h
//  Tinge
//
//  Created by Sergey Dolin on 8/20/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuthStorage : NSObject
+(void)storeAccessToken:(NSString*)token forProvider:(NSString*)provider;
+(NSString*)accessTokenOfProvider:(NSString*)provider;
+(BOOL) isAccessTokenValid:(NSString*)provider;
+(void) setAccessTokenValid:(BOOL)valid forProvider:(NSString*)provider;

@end
