//
//  TextFieldView.m
//  Tinge
//
//  Created by Sergey Dolin on 9/14/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "TextFieldView.h"
#import <Carbon/Carbon.h>

@implementation TextFieldView {
    @private
//    NSView* _parent;
//    NSObject<TextFieldProtocol>* _textDelegate;
}

//@synthesize textDelegate=_textDelegate;

-(TextFieldView*)initWithFrame:(NSRect)frame{ // andParent:(NSView*)parent{
    self=[super initWithFrame:frame];
    if (self){
        self.bordered=NO;
        self.bezeled = NO;
        self.font=[NSFont systemFontOfSize:18];
    
//        _parent=parent;
//        [_parent addSubview:self];
    }
    return self;
};

/*
-(void)moveToFront{
    [self removeFromSuperview];
    [_parent addSubview:self];
}*/

- (BOOL)becomeFirstResponder
{
  //  [self moveToFront];
    BOOL status = [super becomeFirstResponder];
    return status;
}



@end
