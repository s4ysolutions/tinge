//
//  EditorDraw.h
//  Tinge
//
//  Created by Sergey Dolin on 8/18/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tool.h"

@protocol EditorModel <NSObject>
- (void) drawInContext:(CGContextRef)context;
- (Tool*) toolByPointAtEnd:(CGPoint)point;
- (Tool*) toolByPointAtBegin:(CGPoint)point;
- (Tool*) toolByPoint:(CGPoint)point;
- (void) removeActiveTool;
- (void) addEditedToolWithUndo:(Tool*) tool original:(Tool*)original;
- (void) addOrRemoveToolWithUndo:(Tool*) tool;
- (Tool*) activeTool;
- (BOOL) activateTool:(Tool*) tool;
//- (void) setActiveTool:(Tool*)tool;
- (Tool*) pastedTool;
- (void) copyActiveTool;
- (BOOL) activateToolByPoint:(CGPoint) point;
- (void) deactiviteAllTools;
- (CGSize)imageSize;
- (void) exportToLocal;
- (void) exportToDropbox;
- (void) exportToClipboard;
@end
