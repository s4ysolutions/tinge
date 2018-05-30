//
//  ScreenshotView.m
//  Tinge
//
//  Created by Sergey Dolin on 8/2/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "ScreenshotView.h"
#import "CropView.h"

@implementation ScreenshotView {
@private
    CGImageRef _image;
    CropView* _cropView;
    NSObject<ScreenshotDelegator>* _delegator;
}

- (id)initWithCGImage:(CGImageRef)anImage
{
    NSRect frame=NSMakeRect(0, 0, CGImageGetWidth(anImage), CGImageGetHeight(anImage));
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
    
    CGInterpolationQuality q = NSImageInterpolationHigh;
    CGContextSetInterpolationQuality(context, q);
    
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
    CGImageRef cropped=CGImageCreateWithImageInRect(_image,CGRectMake(a.x, CGImageGetHeight(_image)-b.y, b.x-a.x, b.y-a.y));
    if (cropped)
        [_delegator screenshot:_image wasCropped: cropped];
    else
        NSLog(@"Can't crop screenshot %f,%f %f,%f",a.x,a.y,b.x-a.x,b.y-a.y);
    CGImageRelease(cropped);
};

@end
