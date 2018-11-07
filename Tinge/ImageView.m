//
//  ImageView.m
//  Tinge
//
//  Created by Sergey Dolin on 6/5/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "ImageView.h"
#import "ToolPaletteWindowController.h"
#import "Tool.h"
#import "Constants.h"

@implementation ImageView {
@private
    CGPoint _p1;
    Tool *_tool;
    Tool *_editedTool;
    BOOL _movingByEnd;
    BOOL _movingByBegin;
    BOOL _moving;
    CGPoint _movingPoint;
    CGPoint _mdownPoint;
}

- (void)awakeFromNib
{
}

- (void)dealloc {

    [_tool release];
    [_editedTool release];
    [super dealloc];
}

/* Does the drawing for the ImageDocument view. */
- (void) drawRect:(NSRect)rect
{
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    [editorModel drawInContext:context];
    
    [_tool draw:context];
}

-(void)resetTool{
    [NSCursor unhide];
    [_tool release];
    _tool=nil;
    [self setNeedsDisplay:YES];
    [self setupCursor];
}

-(BOOL)significantMoveFromPoint:(CGPoint)point{
    float d=sqrt((point.x-_mdownPoint.x)*(point.x-_mdownPoint.x)+(point.y-_mdownPoint.y)*(point.y-_mdownPoint.y));
    return d>SIGNIFICANT_MOVE;
}


- (void)mouseDown:(NSEvent *)event {
    CGPoint p=[event locationInWindow];
    _mdownPoint=p;

    Tool *tb=nil;
    Tool *te=nil;
    Tool *t=nil;
    tb=[[editorModel toolByPointAtBegin:p] retain];
    if (!tb){
        te=[[editorModel toolByPointAtEnd:p] retain];
        if (!te){
            t=[[editorModel toolByPoint:p] retain];
        }
    }
    
    [_tool release];
    _tool=nil;
    [_editedTool release];
    _editedTool=nil;
    [editorModel deactiviteAllTools];
    _movingByBegin=NO;
    _movingByEnd=NO;
    _moving=NO;
    
    if (tb){
        _movingByBegin=YES;
        _tool=tb;
    }else if (te){
        _movingByEnd=YES;
        _tool=te;
    }else if (t){
        _moving=YES;
        _tool=t;
        _movingPoint=p;
    }else{
    };
    _editedTool=[_tool copy];
    _p1=p;
    [self setNeedsDisplay:YES];
    [NSCursor hide];
}



- (void)mouseUp:(NSEvent *)event {
    
    if (![self significantMoveFromPoint:[event locationInWindow]]) {
        [editorModel activateToolByPoint:[event locationInWindow] ];
    }else{
        if (_movingByEnd || _movingByBegin || _moving)
            [editorModel addEditedToolWithUndo:_tool original:_editedTool];
        else 
            [editorModel addOrRemoveToolWithUndo:_tool];
    };
    [self resetTool];
}

- (void)mouseDragged:(NSEvent *)event {
    if (_movingByBegin){
        [_tool setPoints: [event locationInWindow] and:[_tool p2]];
    }else if (_movingByEnd) {
        [_tool setPoints: [_tool p1] and:[event locationInWindow]];
    }else if (_moving) {
        [_tool moveFromPoint:_movingPoint toPoint:[event locationInWindow]];
        _movingPoint=[event locationInWindow];
    }else {
        if (nil==_tool){
            _tool=[[ToolPaletteWindowController sharedToolPaletteController] toolSelected:self];
            //[_tool setActive:YES];
        }
        [_tool setPoints: _p1 and: [event locationInWindow]];
    }
    [_tool doDragging];
    [self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)event {
    [self setupCursor];
}

-(void)setupCursor{
    CGPoint p=[self convertPoint:[self.window convertScreenToBase:[NSEvent mouseLocation]] fromView:nil];
    
    if ([editorModel toolByPointAtBegin:p] || [editorModel toolByPointAtEnd:p]){
        [[NSCursor closedHandCursor] set];
    }else if ([editorModel toolByPoint:p]){
        [[NSCursor openHandCursor] set];
    }else{
        [[NSCursor arrowCursor] set];
    }
    
};


- (BOOL)acceptsFirstResponder
{
    return YES;
}
/*
- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender{
    if ((
         action==@selector(delete:)||
         action==@selector(copy:)||
         action==@selector(cut:)
         )
        &&
        [editorModel activeTool]
        ){
        return YES;
    }
    return [self can];
}
*/
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item{
    SEL action = [item action];
    if (
         action==@selector(delete:)||
         action==@selector(copy:)||
         action==@selector(cut:)
        ){
        return !![editorModel activeTool];
    }
    if (action==@selector(paste:)){
        return !![editorModel pastedTool];
    }
    return YES;
};

- (void)copy:(id)sender {
    [editorModel copyActiveTool];
}

- (void)cut:(id)sender {
    [editorModel copyActiveTool];
    [editorModel removeActiveTool];
    [self resetTool];
}

- (void)paste:(id)sender {
    Tool* pasted=[editorModel pastedTool];
    [self resetTool];
    if (pasted){
        pasted=[pasted copy];
        [editorModel addOrRemoveToolWithUndo:pasted];
        [editorModel activateTool:pasted];
        [pasted release];
    }
}


- (void)delete:(id)sender {
    [editorModel removeActiveTool];
    [self resetTool];
}

- (void)keyDown:(NSEvent*)event
{
    if ( kVK_Delete == event.keyCode )
    {
        [self delete:self];
    }
    else if (kVK_ANSI_C == event.keyCode && event.modifierFlags & NSCommandKeyMask && event.modifierFlags & NSShiftKeyMask) {
      [editorModel exportToClipboard];
    }else{
        [super keyDown:event];
    }
}


@end
