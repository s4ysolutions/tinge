//
//  TextFieldView.h
//  Tinge
//
//  Created by Sergey Dolin on 9/14/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Tool.h"
//#import "TextFieldProtocol.h"

@interface TextFieldView : NSTextField {
    
}
-(TextFieldView*)initWithFrame:(NSRect)frame;
// andParent:(NSView*)parent;
//-(void)moveToFront;

//@property (retain) NSObject<TextFieldProtocol>* textDelegate;
@end
