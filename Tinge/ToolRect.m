//
//  ToolRect.m
//  Tinge
//
//  Created by Sergey Dolin on 9/13/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "ToolRect.h"
#import "Constants.h"

@implementation ToolRect

- (id)copyWithZone:(NSZone *)zone
{
    ToolRect* copy=[[ToolRect allocWithZone:zone] initFromTool:self];
    return copy;
}


@end
