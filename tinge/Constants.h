//
//  Constants.h
//  Tinge
//
//  Created by Sergey Dolin on 9/13/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#ifndef Tinge_Constants_h
#define Tinge_Constants_h

#import <Cocoa/Cocoa.h>

#define SIGNIFICANT_MOVE 10
#define RADIUS 8
#define BORDER 4

// Captured images are in pixels. Sizes on screen are in points: points = pixels / scale.
// The scale is pixels per point of the given display mode.
// CGDisplayPixelsWide is not used: on Retina it returns the width in points.
static inline CGFloat TingePixelsPerPoint(CGDirectDisplayID display)
{
    CGDisplayModeRef mode = CGDisplayCopyDisplayMode(display);
    if (mode == NULL)
        return 1;
    size_t widthInPoints = CGDisplayModeGetWidth(mode);
    CGFloat scale = widthInPoints > 0 ? (CGFloat)CGDisplayModeGetPixelWidth(mode) / widthInPoints : 1;
    CGDisplayModeRelease(mode);
    return scale > 0 ? scale : 1;
}


#endif
