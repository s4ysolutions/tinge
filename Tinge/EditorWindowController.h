//
//  EditorWindowController.h
//  Tinge
//
//  Created by Sergey Dolin on 8/17/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EditorModel.h"
#import "ImageView.h"

@interface EditorWindowController : NSWindowController <EditorModel,NSWindowDelegate> {
    IBOutlet ImageView *imageView;
}
+(EditorWindowController*)startEdit:(CGImageRef)image;
-(EditorWindowController*)initWithImageRef:(CGImageRef)image;
-(IBAction) exportToClipboard:(id)sender;
-(IBAction) exportToLocal:(id)sender;
-(IBAction) exportToDropbox:(id)sender;
//-(void) reexport;
@end
