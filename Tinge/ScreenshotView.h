//
//  ScreenshotView.h
//  Tinge
//
//  Created by Sergey Dolin on 8/2/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScreenshotDelegator.h"

@interface ScreenshotView : NSView

//@property(readonly) CropView* cropView;
- (id)initWithCGImage:(CGImageRef)anImage;
- (void)screenshotWasCroppedWithA:(CGPoint) a andB:(CGPoint) b;
- (void)setDelegator:(NSObject<ScreenshotDelegator> *)delegator;

@end
