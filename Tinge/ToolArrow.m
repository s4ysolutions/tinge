//
//  ToolArrow.m
//  Tinge
//
//  Created by Sergey Dolin on 8/12/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "ToolArrow.h"
#import <math.h>

#define ARROW_START_SIZE_HALF 5.0

#define ARROW_END_SIZE_HALF 10.0
#define ARROW_END_CENTER_OFFSET 20.0
#define ARROW_END_SIZE_THIKNESS 2.0

@implementation ToolArrow {
}



+ (CGMutablePathRef)endPath {
    static CGMutablePathRef _endPath;
    if (_endPath==NULL){
        double a=atan((ARROW_END_SIZE_HALF*1.2)/(ARROW_END_CENTER_OFFSET*1.0));
        _endPath = CGPathCreateMutable();
        CGPathAddArc(_endPath,NULL,-ARROW_END_CENTER_OFFSET-ARROW_END_SIZE_HALF, 0,ARROW_END_CENTER_OFFSET,a,2*M_PI-a,true);
        CGPathAddLineToPoint(_endPath, NULL, ARROW_END_SIZE_HALF, 0);
        CGPathCloseSubpath(_endPath);
    }
    return _endPath;
};
/*
-(id)initFromTool:(ToolArrow*)tool{
    self=[super initFromTool:tool];
    if (self){
    }
    return self;
}
*/
- (id)copyWithZone:(NSZone *)zone
{
    ToolArrow* copy=[[ToolArrow allocWithZone:zone] initFromTool:self];
    return copy;
}

- (void)dealloc {
    [super dealloc];
}



-(double)angle {
    double a=0.0;
    
    if (_p1.x!=_p2.x){
        a=atan2f((_p2.y-_p1.y),(_p2.x-_p1.x));
    }else if (_p1.y<_p2.y){
        a=M_PI*4/3;
    }else if (_p1.y>_p2.y){
        a=M_PI/2;
    }
    return a;
}

-(CGPathRef) path1WithAngle:(double)a{
    CGAffineTransform t;
    CGPathRef p;
    t=CGAffineTransformRotate(CGAffineTransformMakeTranslation(_p2.x,_p2.y),a);
    p=CGPathCreateCopyByTransformingPath([ToolArrow endPath],&t);
    return p;
}

-(CGPathRef) path2WithAngle:(double)a{
    CGMutablePathRef pm = CGPathCreateMutable();
    CGPathAddArc(pm,NULL,_p1.x, _p1.y,ARROW_START_SIZE_HALF,M_PI/2.0+a,1.5*M_PI+a,false);
    float dx=ARROW_END_SIZE_THIKNESS*sinf(a);
    float dy=ARROW_END_SIZE_THIKNESS*cosf(a);
    CGPathAddLineToPoint(pm, NULL, _p2.x+dx, _p2.y-dy);
    CGPathAddLineToPoint(pm, NULL, _p2.x-dx, _p2.y+dy);
    CGPathCloseSubpath(pm);

    return pm;
}


-(BOOL)draw:(CGContextRef)context{
    [self setupContext:context];
    
    double a=[self angle];
    CGPathRef p;
    
    p = [self path1WithAngle:a];
    CGContextAddPath(context, p);
    CGContextFillPath(context);
    CGPathRelease(p);

    p = [self path2WithAngle:a];

    CGContextAddPath(context, p);
    CGContextFillPath(context);
    CGPathRelease(p);

    [super drawActive:context];
    return YES;//[super draw:context];
};

-(BOOL)containsPoint:(CGPoint)point{
    double a=[self angle];
    BOOL ret;
    
    CGPathRef p = [self path1WithAngle:a];
    ret=CGPathContainsPoint(p,NULL,point,false);
    CGPathRelease(p);
    
    if (ret) return YES;
    
    p = [self path2WithAngle:a];
    ret=CGPathContainsPoint(p,NULL,point,false);
    CGPathRelease(p);
    return ret;
    
};

@end
