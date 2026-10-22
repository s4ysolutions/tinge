//
//  ScreenshotView.m
//  Tinge
//
//  Created by Sergey Dolin on 8/2/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "ScreenshotView.h"
#import "CropView.h"
#import "Constants.h"

@implementation ScreenshotView {
@private
    CGImageRef _image;
    CropView* _cropView;
    NSObject<ScreenshotDelegator>* _delegator;
    CGFloat _scale;
}

- (id)initWithCGImage:(CGImageRef)anImage display:(CGDirectDisplayID)display
{
    _scale=TingePixelsPerPoint(display);
    NSRect frame=NSMakeRect(0, 0, CGImageGetWidth(anImage)/_scale, CGImageGetHeight(anImage)/_scale);
    self = [super initWithFrame:frame];
    if (self) {
        _image = (CGImageRef)CFRetain(anImage);
        _cropView = [[CropView alloc] initWithFrame:frame];
        [_cropView setScreenshotView:self];
        [self addSubview:_cropView];
        [_cropView release];
    }
    return self;
}

- (void)dealloc {
    if (_image)
        CFRelease(_image);
    [super dealloc];
}


- (void)setDelegator:(NSObject<ScreenshotDelegator> *)delegator{
    [_delegator release];
    _delegator=[delegator retain];
}


- (void) drawImage
{
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    if (context==nil)
        return;
    
    if (_image==nil)
        return;
    
    CGRect imageRect = [self frame];
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextDrawImage(context, imageRect, _image);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawImage];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)screenshotWasCroppedWithA:(CGPoint) a andB:(CGPoint) b
{
    CGRect rs = CGRectMake(a.x*_scale,
                           CGImageGetHeight(_image)-b.y*_scale,
                           (b.x-a.x)*_scale,
                           (b.y-a.y)*_scale);
    
    CGImageRef cropped=CGImageCreateWithImageInRect(_image,rs);
    if (cropped)
        [_delegator screenshot:_image wasCropped: cropped];
    else
        NSLog(@"Can't crop screenshot %f,%f %f,%f",a.x,a.y,b.x-a.x,b.y-a.y);
    CGImageRelease(cropped);
};

@end
