//
//  OAuthStorage.m
//  Tinge
//
//  Created by Sergey Dolin on 8/20/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "OAuthStorage.h"

@implementation OAuthStorage
+(void)storeAccessToken:(NSString*)token forProvider:(NSString*)provider{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:provider];
    [OAuthStorage setAccessTokenValid:YES forProvider:provider];
};
+(NSString*)accessTokenOfProvider:(NSString*)provider{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* token=[defaults stringForKey:provider];
    if ([@"" isEqualToString:token])
        return nil;
    return token;
};
+(BOOL) isAccessTokenValid:(NSString*)provider{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* valid=[defaults stringForKey:[provider stringByAppendingString:@"_valid"]];
    return (valid==nil || [@"YES" isEqualToString:valid]);
};

+(void) setAccessTokenValid:(BOOL)valid forProvider:(NSString*)provider{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:valid?@"YES":@"NO" forKey:[provider stringByAppendingString:@"_valid"]];
};

@end
