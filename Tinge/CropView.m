//
//  CropView.m
//  Tinge
//
//  Created by Sergey Dolin on 8/2/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "CropView.h"

@implementation CropView{
@private
    CGPoint _a;
    CGPoint _b;
    ScreenshotView* _screenshotView;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    _a.x=0;
    _a.y=0;
    _b.x=frame.size.width;
    _b.y=frame.size.height;
    
    if (self) {
    }
    return self;
}

- (void)dealloc {
    // [_screenshotView release]; //is not called - mory leak
    [super dealloc];
}

- (void)setScreenshotView:(ScreenshotView *)screenshotView{
    //[_screenshotView release];
    _screenshotView=screenshotView;//[screenshotView retain];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawRects];
}


- (void)drawRects
{
    NSRect bounds=[self bounds];
    CGRect rects[4];
    int n=0;
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    NSPoint a0;
    NSPoint b0;
    
    if (_a.x<_b.x){
        a0.x=_a.x;
        b0.x=_b.x;
    }else{
        a0.x=_b.x;
        b0.x=_a.x;
    }
    if (_a.y<_b.y){
        a0.y=_a.y;
        b0.y=_b.y;
    }else{
        a0.y=_b.y;
        b0.y=_a.y;
    }
    // CGContextClearRect (context, bounds);
    
    CGColorRef color=CGColorCreateGenericRGB(0,0,0,0.25);
    CGContextSetFillColorWithColor(context, color);
    CGColorRelease(color);

   // NSLog(@"Bounds %f,%f %f,%f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
   // NSLog(@"draw a0=%f,%f b0=%f,%f",a0.x,a0.y,b0.x,b0.y);
    
    if (a0.x>0 && a0.y<bounds.size.height){
        rects[n]=CGRectMake(0, a0.y, a0.x, bounds.size.height-a0.y);
//        rects[n]=CGRectMake(0, 0, a0.x, bounds.size.height-a0.y);
//        rects[n]=CGRectMake(50, 100, 200,400);
        // CGContextStrokeRect(context, rects[n]);
//        NSLog(@"1 %f,%f %f,%f",rects[n].origin.x,rects[n].origin.y,rects[n].size.width,rects[n].size.height);
        n++;
    }
    if (b0.y<bounds.size.height && a0.x<bounds.size.width){
        rects[n]=CGRectMake(a0.x, b0.y+1, bounds.size.width-a0.x, bounds.size.height-b0.y);
        //rects[n]=CGRectMake(a0.x, a0.y, bounds.size.width-a0.x, bounds.size.height-a0.y);
        // CGContextStrokeRect(context, rects[n]);
        // NSLog(@"2 %f,%f %f,%f",rects[n].origin.x,rects[n].origin.y,rects[n].size.width,rects[n].size.height);
        n++;
    }
    if (b0.x<bounds.size.width && b0.y>1){
        rects[n]=CGRectMake(b0.x, 0, bounds.size.width-b0.x,b0.y+1);
        // CGContextStrokeRect(context, rects[n]);
        // NSLog(@"3 %f,%f %f,%f",rects[n].origin.x,rects[n].origin.y,rects[n].size.width,rects[n].size.height);
        n++;
    }
    if (b0.x>0 && a0.y>0){
        rects[n]=CGRectMake(0, 0, b0.x, a0.y);
        //CGContextStrokeRect(context, rects[n]);
        //NSLog(@"4 %f,%f %f,%f",rects[n].origin.x,rects[n].origin.y,rects[n].size.width,rects[n].size.height);
        n++;
    }
    
    if (n>0){
        CGContextFillRects(context,rects,n);
    }else{
        CGContextFillRect(context, bounds);
    }
    
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
    _a=[theEvent locationInWindow];
    _a.y=_a.y;//-1;
    _b=[theEvent locationInWindow];
    _b.y=_b.y-1;
    //NSLog(@"Down %f,%f %f,%f",_a.x,_a.y,_b.x-_a.x,_b.y-_a.y);
    //[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (_screenshotView!=nil){
        NSPoint a0;
        NSPoint b0;
        
        //NSLog(@"Up %f,%f %f,%f",_a.x,_a.y,_b.x-_a.x,_b.y-_a.y);
        
        if (_a.x<_b.x){
            a0.x=_a.x;
            b0.x=_b.x;
        }else{
            a0.x=_b.x;
            b0.x=_a.x;
        }
        if (_a.y<_b.y){
            a0.y=_a.y;
            b0.y=_b.y;
        }else{
            a0.y=_b.y;
            b0.y=_a.y;
        }
        
        if (b0.x>a0.x && a0.y<b0.y){
            [_screenshotView screenshotWasCroppedWithA:a0 andB:b0];
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    _b=[theEvent locationInWindow];
    _b.y=_b.y;//-1;
    //NSLog(@"dragged %f,%f",_b.x,_b.y);
    [self setNeedsDisplay:YES];
}

@end
