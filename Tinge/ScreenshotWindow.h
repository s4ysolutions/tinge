//
//  ScreenshotWindow.h
//  Tinge
//
//  Created by Sergey Dolin on 8/2/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScreenshotDelegator.h"

@interface ScreenshotWindow : NSWindow <NSWindowDelegate>
- (id)initWithCGImage:(CGImageRef)anImage andDelegator:(NSObject<ScreenshotDelegator>*)delegator;
@end
