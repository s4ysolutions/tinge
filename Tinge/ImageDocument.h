//
//  ImageDocument.h
//  Tinge
//
//  Created by Sergey Dolin on 6/5/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Tool.h"

@class ImageView;

@interface ImageDocument : NSDocument <NSWindowDelegate> {
@private
    IBOutlet ImageView *imageView;
    IBOutlet NSScrollView *scrollView;
    
    CGImageRef image;
}

//@property(readonly,assign) NSArray* tools;
- (void) addTool:(Tool*) tool;
- (void) setCGImage:(CGImageRef)anImage;
- (CGImageRef)currentCGImage;
- (CGSize) imageSize;
- (void) drawIn:(CGContextRef)context;

@end
