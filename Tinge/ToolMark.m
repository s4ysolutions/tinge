//
//  ToolMark.m
//  Tinge
//
//  Created by Sergey Dolin on 9/14/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "ToolMark.h"
#define RADIUS_MARK 0

@implementation ToolMark

- (id)copyWithZone:(NSZone *)zone
{
    ToolMark* copy=[[ToolMark allocWithZone:zone] initFromTool:self];
    return copy;
}

-(CGPathRef) pathBorder{
    CGMutablePathRef pm = CGPathCreateMutable();
    float x1,x2,y1,y2;
    
    if (_p1.x<_p2.x){
        x1=_p1.x;
        x2=_p2.x;
    }else{
        x2=_p1.x;
        x1=_p2.x;
    }
    
    if (_p1.y<_p2.y){
        y1=_p1.y;
        y2=_p2.y;
    }else{
        y2=_p1.y;
        y1=_p2.y;
    }
    
    float r=RADIUS_MARK;
    if (r*2>x2-x1) r=(x2-x1)/2;
    if (r*2>y2-y1) r=(y2-y1)/2;
    
    CGPathMoveToPoint(pm,NULL, x1+r, y1+r);
//    CGPathAddArc(pm,NULL,x1+r, y1+r,r,1.5*M_PI,M_PI,true);
    CGPathAddLineToPoint(pm, NULL, x1, y2-r);//left side
//    CGPathAddArc(pm,NULL,x1+r, y2-r,r,M_PI,M_PI/2,true);
    CGPathAddLineToPoint(pm, NULL, x2-r, y2);//top
//    CGPathAddArc(pm,NULL,x2-r, y2-r,r,M_PI/2,0,true);
    CGPathAddLineToPoint(pm, NULL, x2, y1+r);//right
//    CGPathAddArc(pm,NULL,x2-r, y1+r,r,0,1.5*M_PI,true);
    CGPathCloseSubpath(pm);
    return pm;
}

-(BOOL)drawExterior:(CGContextRef)context{
    return NO;
}

-(BOOL)drawInterior:(CGContextRef)context{
    if (CGColorGetNumberOfComponents(self.color) ==4) {
        const CGFloat *colors=CGColorGetComponents(self.color);
        CGColorRef c=CGColorCreateGenericRGB(colors[0],colors[1],colors[2],0.4);
        CGContextSetFillColorWithColor(context, c);
        CGColorRelease(c);
    }else
        CGContextSetFillColorWithColor(context, self.color);
    
    CGPathRef p;
    
    p = [self pathBorder];
    CGContextAddPath(context, p);
    CGContextFillPath(context);
    CGPathRelease(p);
    return YES;
}
@end
