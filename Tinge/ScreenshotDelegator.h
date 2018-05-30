//
//  ScreenshotDelegator.h
//  Tinge
//
//  Created by Sergey Dolin on 8/4/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScreenshotDelegator <NSObject>
- (void)screenshot:(CGImageRef)screenshot wasCropped:(CGImageRef) cropped;
@end
