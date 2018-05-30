//
//  Tool.h
//  Tinge
//
//  Created by Sergey Dolin on 8/12/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ImageView.h"

extern NSString *ToolShouldBeDeletedNotification;

@interface Tool : NSObject<NSCopying>  {
    @protected
    CGPoint _p1;
    CGPoint _p2;
    CGColorRef _color;
}

@property(retain,readonly) NSView* parent;
//@property(assign) BOOL active;
@property(readonly) BOOL completed;
@property(readonly) CGRect frame;
@property(readonly) CGFloat diameter;
@property(readonly) CGPoint center;
@property(readonly) CGPoint p1;
@property(readonly) CGPoint p2;

-(id)init:(NSView*)parent;
-(id)initFromTool:(Tool*)tool;
-(void)copyFrom:(Tool*)tool;
-(BOOL)containsPoint:(CGPoint)point;
-(BOOL)beginContainsPoint:(CGPoint)point;
-(BOOL)endContainsPoint:(CGPoint)point;
-(BOOL)draw:(CGContextRef)context;
-(void)drawActive:(CGContextRef)context;
-(void)setPoints:(CGPoint)p1 and:(CGPoint)p2;
-(void)moveFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2;
-(CGColorRef)color;
-(void)setColor:(CGColorRef) color;
-(void)setupContext:(CGContextRef) context;
-(void)show;
-(void)hide;
-(void)doDragging;
-(BOOL)active;
-(void)setActive:(BOOL) active;
-(void)added;
@end
