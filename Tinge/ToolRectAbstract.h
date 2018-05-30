//
//  ToolRectAbstract.h
//  Tinge
//
//  Created by Sergey Dolin on 9/13/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "Tool.h"

@interface ToolRectAbstract : Tool
-(CGPathRef) pathBorder;
-(BOOL)drawInterior:(CGContextRef)context;
-(BOOL)drawExterior:(CGContextRef)context;
-(NSRect)frameInner;
@end
