//
//  ToolPaletteWindowController.h
//  Tinge
//
//  Created by Sergey Dolin on 8/8/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Tool.h"
#import "EditorModel.h"



@interface ToolPaletteWindowController : NSWindowController {
    IBOutlet NSMenu *menuColor;
    IBOutlet NSView *menuColorView;
    IBOutlet NSMatrix *matrixTools;
}

@property (retain) IBOutlet NSMenu *menuColor;
@property (retain) IBOutlet NSView *menuColorView;

+ (void)addToWindow:(NSWindow*)parentWindow withEditor:(NSObject<EditorModel>*)editor;
+ (void)removeFromWindow:(NSWindow*)window;

+ (id)sharedToolPaletteController;

- (IBAction)selectToolArrowAction:(id)sender;
- (IBAction)selectToolTextAction:(id)sender;
- (IBAction)selectToolRectAction:(id)sender;
- (IBAction)selectToolMarkAction:(id)sender;

- (IBAction)selectColorAction:(id)sender;

- (IBAction)selectColorBlackAction:(id)sender;
- (IBAction)selectColorBlueAction:(id)sender;
- (IBAction)selectColorGreenAction:(id)sender;
- (IBAction)selectColorOrangeAction:(id)sender;
- (IBAction)selectColorPurpleAction:(id)sender;
- (IBAction)selectColorRedAction:(id)sender;
- (IBAction)selectColorYellowAction:(id)sender;
- (IBAction)selectColorWhiteAction:(id)sender;

- (IBAction)exportToLocal:(id)sender;
- (IBAction)exportToCloud:(id)sender;
- (IBAction)exportToDropbox:(id)sender;

- (Tool*)toolSelected:(NSView*)parent;
- (CGColorRef) selectedColor;

- (CGColorRef)colorBlack;
- (CGColorRef)colorBlue;
- (CGColorRef)colorGreen;
- (CGColorRef)colorOrange;
- (CGColorRef)colorPurple;
- (CGColorRef)colorRed;
- (CGColorRef)colorYellow;
- (CGColorRef)colorWhite;
@end


extern NSString *ToolDidChangeNotification;
extern NSString *ColorDidChangeNotification;
