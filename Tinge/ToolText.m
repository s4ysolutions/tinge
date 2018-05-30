//
//  ToolText.m
//  Tinge
//
//  Created by Sergey Dolin on 9/13/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "ToolText.h"
#import "ImageView.h"
#import "TextFieldView.h"

@implementation ToolText {
    @private
    NSString* _text;
    TextFieldView* _textField;
    NSBitmapImageRep* _textBitmap;
}

-(id)init:(ImageView*)parent{
    self=[super init:parent];
    if (self){
        //_textField=[[TextFieldView alloc] initWithFrame:self.frameInner andParent:parent];
        self.color=self.color;//update text field color
        //self.text=@"123";
    }
    return self;
}

-(id)initFromToolText:(ToolText*)tool{
    self=[super initFromTool:tool];
    if (self){
        self.text=tool.text;
        //[_textField setStringValue:tool.text];
        //[_textField setHidden:YES];
    }
    return self;
}

-(void)dealloc{
    [_textField release];
    [_text release];
    [_textBitmap release];
    [super dealloc];
}

-(void)setPoints:(CGPoint)p1 and:(CGPoint)p2{
    [super setPoints:p1 and:p2];
    [self updateBitmap];

//    [_textField setFrame:self.frameInner];
};

-(void)setText:(NSString *)text{
    [_text release];
    _text=[text retain];
    _textField.stringValue=text;
}

-(NSString*)text{
    return _text;
//    return _textField.stringValue;
};


- (id)copyWithZone:(NSZone *)zone
{
    Tool* copy=[[ToolText allocWithZone:zone] initFromToolText:self];
    return copy;
}

-(BOOL)drawExterior:(CGContextRef)context{
    CGContextSetFillColorWithColor(context, CGColorGetConstantColor(kCGColorWhite));
    
    CGPathRef p;
    
    p = [self pathBorder];
    CGContextAddPath(context, p);
    CGContextFillPath(context);
    CGPathRelease(p);
    
    if (_textBitmap){
        NSInteger     rowBytes, width, height;
        
        rowBytes = [_textBitmap bytesPerRow];
        width = [_textBitmap pixelsWide];
        height = [_textBitmap pixelsHigh];
        CGDataProviderRef provider = CGDataProviderCreateWithData( _textBitmap, [_textBitmap bitmapData], rowBytes * height, NULL );
        CGColorSpaceRef colorspace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB );
        CGBitmapInfo    bitsInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedLast;
        
        CGImageRef image = CGImageCreate( width, height, 8, 32, rowBytes, colorspace, bitsInfo, provider, NULL, NO, kCGRenderingIntentDefault );
        CGRect r=CGRectMake(self.frameInner.origin.x, self.frameInner.origin.y, self.frameInner.size.width, self.frameInner.size.height);
        CGContextDrawImage(context, r, image);
        
        CGDataProviderRelease( provider );
        CGColorSpaceRelease(colorspace);
        CGImageRelease(image);
    }
    
    return YES;
};

-(BOOL)drawInterior:(CGContextRef)context{
    return YES;
};
/*
-(void)show{
    [_textField setHidden:NO];
};

-(void)hide{
    [_textField setHidden:YES];
};*/

/*
-(BOOL)containsPoint:(CGPoint)point{
    BOOL ret=[super containsPoint:point];
    if (!ret) return NO;
    return !NSPointInRect(point,[self frameInner]);
};
*/

-(void)setColor:(CGColorRef) color{
    [super setColor:color];
    _textField.textColor=[NSColor colorWithCIColor: [CIColor colorWithCGColor: self.color]];
    [self updateBitmap];
};

-(void)updateBitmap{
    if (!_textField)
        [self addTextField];
    [self updateTextBitmapWithText:_textField.stringValue];
    [self removeTextField];
}

-(void)addTextField{
    _textField=[[TextFieldView alloc] initWithFrame:self.frameInner ];// andParent:self.parent];
    _textField.textColor=[NSColor colorWithCIColor: [CIColor colorWithCGColor: self.color]];
    _textField.stringValue=self.text==nil?@"":self.text;
    _textField.delegate=self;
    [self.parent addSubview: _textField];
}

-(void)removeTextField{
    [_textField removeFromSuperview];
    [_textField release];
    _textField=nil;
}

-(void)updateTextBitmapWithText:(NSString*) text{
    self.text=text;
    [_textBitmap release];
    [_textField.currentEditor setSelectedRange:NSMakeRange(_textField.currentEditor.selectedRange.location, 0)];
    _textBitmap = [_textField bitmapImageRepForCachingDisplayInRect:_textField.bounds];
    [_textField cacheDisplayInRect:_textField.bounds toBitmapImageRep:_textBitmap];
    [_textBitmap retain];
}

-(void)setActive:(BOOL)active{
    [super setActive:active];
    if (active){
        [self addTextField];
        [self.parent.window makeFirstResponder:_textField];
    }else{
     //   self.text=_textField.stringValue; //set in - (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
        [self removeTextField];
    }
}

#pragma mark textfield delegate

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    [self updateTextBitmapWithText:[fieldEditor.string copy]];
    return YES;
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    
    if (commandSelector == @selector(insertNewline:))
    {
        // new line action:
        // always insert a line-break character and don’t cause the receiver to end editing
        [textView insertNewlineIgnoringFieldEditor:self];
        result = YES;
       // result = NO;
    }
    else if (commandSelector == @selector(deleteBackward:))
    {
        if ([@"" isEqualToString:[textView string]]){
            [self removeTextField];
            [[NSNotificationCenter defaultCenter] postNotificationName:ToolShouldBeDeletedNotification object:self];
            result = YES;
        }else{
            result = NO;
        }
    }
    else if (commandSelector == @selector(insertTab:))
    {
        // tab action:
        // always insert a tab character and don’t cause the receiver to end editing
        [textView insertTabIgnoringFieldEditor:self];
        result = YES;
    }
    
    return result;
}
-(void)added{
    [self addTextField];
    [self.parent.window makeFirstResponder:_textField];    
};

@end
