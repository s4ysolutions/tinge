//
//  ToolRectAbstract.m
//  Tinge
//
//  Created by Sergey Dolin on 9/13/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "ToolRectAbstract.h"
#import "Constants.h"

@implementation ToolRectAbstract


-(NSRect)frameInner{
    float x1,x2,y1,y2;
    [self pointsX1:&x1 Y1:&y1 X2:&x2 Y2:&y2];
    return NSMakeRect(x1+BORDER, y1+BORDER, x2-x1-BORDER*2, y2-y1-BORDER*2);
};

-(void)pointsX1:(float*)x1 Y1:(float*)y1 X2:(float*)x2 Y2:(float*)y2{
    if (_p1.x<_p2.x){
        *x1=_p1.x;
        *x2=_p2.x;
    }else{
        *x2=_p1.x;
        *x1=_p2.x;
    }
    
    if (_p1.y<_p2.y){
        *y1=_p1.y;
        *y2=_p2.y;
    }else{
        *y2=_p1.y;
        *y1=_p2.y;
    }
}

-(CGPathRef) pathBorder{
    CGMutablePathRef pm = CGPathCreateMutable();
    float x1,x2,y1,y2;
    [self pointsX1:&x1 Y1:&y1 X2:&x2 Y2:&y2];
    
    float r=RADIUS;
    if (r*2>x2-x1) r=(x2-x1)/2;
    if (r*2>y2-y1) r=(y2-y1)/2;
    
    CGPathAddArc(pm,NULL,x1+r, y1+r,r,1.5*M_PI,M_PI,true);
    CGPathAddLineToPoint(pm, NULL, x1, y2-r);//left side
    CGPathAddArc(pm,NULL,x1+r, y2-r,r,M_PI,M_PI/2,true);
    CGPathAddLineToPoint(pm, NULL, x2-r, y2);//top
    CGPathAddArc(pm,NULL,x2-r, y2-r,r,M_PI/2,0,true);
    CGPathAddLineToPoint(pm, NULL, x2, y1+r);//right
    CGPathAddArc(pm,NULL,x2-r, y1+r,r,0,1.5*M_PI,true);
    CGPathCloseSubpath(pm);
    return pm;
}
-(BOOL)drawInterior:(CGContextRef)context{
    return YES;
}
-(BOOL)drawExterior:(CGContextRef)context{
    return YES;
}

-(BOOL)draw:(CGContextRef)context{
    [self setupContext:context];

    if ([self drawExterior:context]){
        CGContextSetStrokeColorWithColor(context, self.color);
        CGContextSetLineWidth(context,BORDER);
        
        CGPathRef p;
        
        p = [self pathBorder];
        CGContextAddPath(context, p);
        CGContextStrokePath(context);
        CGPathRelease(p);
    };

    BOOL ret=[self drawInterior:context];
    [super drawActive:context];
    return ret;//[super draw:context];
};

-(BOOL)containsPoint:(CGPoint)point{
    BOOL ret;
    
    CGPathRef p = [self pathBorder];
    ret=CGPathContainsPoint(p,NULL,point,false);
    CGPathRelease(p);
    
    return ret;
    
};
@end
