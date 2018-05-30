//
//  PresentationManager.h
//  Tinge
//
//  Created by Sergey Dolin on 8/7/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PresentationManager : NSObject
+ (void)editorDidOpen;
+ (void)editorDidClose;
+ (void)uploadDidOpen;
+ (void)uploadDidClose;
@end
