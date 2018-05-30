//
//  ToolText.h
//  Tinge
//
//  Created by Sergey Dolin on 9/13/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "ToolRectAbstract.h"

@interface ToolText : ToolRectAbstract<NSTextFieldDelegate>

@property(retain) NSString* text;
/*
 -(NSString*)text;
 -(void)setText:(NSString*)text;
 */
-(void)setActive:(BOOL)active;
@end
