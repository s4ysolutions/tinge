//
//  Tool.m
//  Tinge
//
//  Created by Sergey Dolin on 8/12/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "Tool.h"
#import "ToolPaletteWindowController.h"
#import "Constants.h"

NSString *ToolShouldBeDeletedNotification = @"ToolShouldBeDeletedNotification";

#define MIN_DIAMETER 15
#define ACTIVE_RADIUS 6

@implementation Tool {
    @private
    BOOL _completed;
    BOOL _active;
    CGRect _frame;
    CGFloat _diameter;
    CGPoint _center;
    NSView* _parent;
}

//@synthesize active=_active;
@synthesize frame=_frame;
@synthesize center=_center;
@synthesize diameter=_diameter;
@synthesize parent=_parent;
@synthesize p1=_p1;
@synthesize p2=_p2;


-(id)init:(NSView*)parent{
    self=[super init];
    if (self){
        _parent=[parent retain];
        _completed=NO;
       self.color=[[ToolPaletteWindowController sharedToolPaletteController] selectedColor];
    }
    return self;
}

-(id)initFromTool:(Tool*)tool{
    self=[self init:tool.parent];
    if (self){
        [self setPoints:tool.p1 and:tool.p2];
        self.color=tool.color;
    }
    return self;
}

-(void)dealloc{
    if (_color){
        CGColorRelease(_color);
    }
    [_parent release];
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone
{
    Tool* copy=[[Tool allocWithZone:zone] initFromTool:self];
    return copy;
}

-(void)copyFrom:(Tool*)tool{
    [self setPoints:tool.p1 and:tool.p2];
    self.color=tool.color;
};

-(void)setPoints:(CGPoint) p1 and:(CGPoint)p2{
    _p1=p1;
    _p2=p2;
    _diameter=sqrt((_p2.x-_p1.x)*(_p2.x-_p1.x)+(_p2.y-_p1.y)*(_p2.y-_p1.y));
    if (!_completed){
        _completed=_diameter>SIGNIFICANT_MOVE;
    }
    _frame.origin.x=(_p1.x<_p2.x)?_p1.x:_p2.x;
    _frame.origin.y=(_p1.y<_p2.y)?_p1.y:_p2.y;
    _frame.size.width=ABS(_p1.x-_p2.x);
    _frame.size.height=ABS(_p1.y-_p2.y);
    _center.x=_frame.origin.x+_frame.size.width/2;
    _center.y=_frame.origin.y+_frame.size.height/2;
};

-(void)moveFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2 {
    float dx=p2.x-p1.x;
    float dy=p2.y-p1.y;
    [self setPoints:CGPointMake(_p1.x+dx, _p1.y+dy) and:CGPointMake(_p2.x+dx, _p2.y+dy)];
};


-(void)setupContext:(CGContextRef) context{
    CGContextSetFillColorWithColor(context, _color);
//    CGContextSetStrokeColorWithColor(context, CGColorGetConstantColor(kCGColorWhite));
//    CGContextSetLineWidth(context, 3);
    CGContextSetAllowsAntialiasing(context,true);
};

-(void)drawPoint:(CGPoint)point context:(CGContextRef)context{
    CGRect rect=CGRectMake(point.x-ACTIVE_RADIUS, point.y-ACTIVE_RADIUS, ACTIVE_RADIUS*2, ACTIVE_RADIUS*2);
    CGContextSetFillColorWithColor(context, _color);
    CGContextFillEllipseInRect(context, rect);
    rect.origin.x+=ACTIVE_RADIUS/2;
    rect.origin.y+=ACTIVE_RADIUS/2;
    rect.size.width-=ACTIVE_RADIUS;
    rect.size.height-=ACTIVE_RADIUS;
    CGContextSetFillColorWithColor(context, CGColorGetConstantColor(kCGColorWhite));
    CGContextFillEllipseInRect(context, rect);
   // NSLog(@"point");
}

-(BOOL)containsPoint:(CGPoint)point{
    return NO;
};

-(void)drawActive:(CGContextRef)context{
    if (self.completed && self.active){
        [self drawPoint:_p1 context:context];
        [self drawPoint:_p2 context:context];
    }
}

-(BOOL)circle:(CGPoint)center ofRadius:(double)radius containsPoint:(CGPoint)point{
    double x=point.x-center.x;
    double x2=x*x;
    double y=point.y-center.y;
    double y2=y*y;
    double r2=radius*radius;
    return x2+y2<r2;
}

-(BOOL)beginContainsPoint:(CGPoint)point{
    return [self circle:_p1 ofRadius:ACTIVE_RADIUS containsPoint:point];
}


-(BOOL)endContainsPoint:(CGPoint)point{
    return [self circle:_p2 ofRadius:ACTIVE_RADIUS containsPoint:point];
}

-(BOOL)draw:(CGContextRef)context{
    return NO;
};


-(BOOL)completed{
    return _completed;
}

-(CGColorRef)color{
    return _color;
};

-(void)setColor:(CGColorRef) color{
    if (_color){
        CGColorRelease(_color);
    }
    _color=color;
    if (_color){
        CGColorRetain(_color);
    }
};

-(void)show{
    
};
-(void)hide{
    
};
-(void)startDragging{
    
};
-(void)doDragging{
    
};
-(void)stopDragging{
    
};

-(BOOL)active{
    return _active;
};
-(void)setActive:(BOOL) active{
    _active=active;
};
-(void)added{
    
};


@end
