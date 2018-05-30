//
//  ToolPaletteWindowController.m
//  Tinge
//
//  Created by Sergey Dolin on 8/8/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "ToolPaletteWindowController.h"
#import "ToolArrow.h"
#import "ToolRect.h"
#import "ToolText.h"
#import "ToolMark.h"

NSString *ToolDidChangeNotification = @"SKTSelectedToolDidChange";
NSString *ColorDidChangeNotification = @"SKTSelectedColorDidChange";

@interface ToolPaletteWindowController ()

@end

static int sCount=0;

#define kToolArrow 0
#define kToolText 1
#define kToolRect 2
#define kToolMark 3

#define kColorBlack 0
#define kColorBlue 1
#define kColorGreen 2
#define kColorOrange 3
#define kColorPurple 4
#define kColorRed 5
#define kColorYellow 6
#define kColorWhite 7
#define kColorCount 8

@implementation ToolPaletteWindowController {
    @private
//    CGColorRef _color;
    CGColorRef _colors[kColorCount];
    int _tool;
}

@synthesize menuColor  = _menuColor;
@synthesize menuColorView  = _menuColorView;

+ (id)sharedToolPaletteController {
    static ToolPaletteWindowController *sharedToolPaletteController = nil;
    
    if (!sharedToolPaletteController) {
        sharedToolPaletteController = [[ToolPaletteWindowController alloc] init];
//        NSLog(@"Init %@",sharedToolPaletteController);
    }
    
    return sharedToolPaletteController;
}

- (id)init {
    self = [self initWithWindowNibName:@"ToolPalette"];
    if (self) {
        [self setWindowFrameAutosaveName:@"ToolPalette"];
//        _color=CGColorCreateGenericRGB(0,0,0,1);
        _colors[kColorBlack]=CGColorCreateGenericRGB(0,0,0,1);
        _colors[kColorBlue]=CGColorCreateGenericRGB(0x1a/256.0,0x34/256.0,0xf3/256.0,1);
        _colors[kColorGreen]=CGColorCreateGenericRGB(0x6a/256.0,0xf2/256.0,0x37/256.0,1);
        _colors[kColorOrange]=CGColorCreateGenericRGB(0xed/256.0,0x7f/256.0,0x29/256.0,1);
        _colors[kColorPurple]=CGColorCreateGenericRGB(0x82/256.0,0x25/256.0,0x80/256.0,1);
        _colors[kColorRed]=CGColorCreateGenericRGB(0xe5/256.0,0x29/256.0,0x1d/256.0,1);
        _colors[kColorYellow]=CGColorCreateGenericRGB(0xfd/256.0,0xf7/256.0,0x3f/256.0,1);
        _colors[kColorWhite]=CGColorCreateGenericRGB(1,1,1,1);
        
        NSDictionary *appDefaults = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     [NSNumber numberWithInt:kColorRed],@"color0",
                                     [NSNumber numberWithInt:kColorRed],@"color1",
                                     [NSNumber numberWithInt:kColorRed],@"color2",
                                     [NSNumber numberWithInt:kColorYellow],@"color3",
                                     nil];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    }
    
    return self;
}

-(void)dealloc{
    for (int i=0;i<kColorCount;i++)
        CGColorRelease(_colors[i]);
    [super dealloc];
}

+ (void)show {
    if (sCount==0){
        [[ToolPaletteWindowController sharedToolPaletteController] showWindow:self];
    }
    sCount++;
}

+ (void)hide {
    sCount--;
    if (sCount==0){
        [[ToolPaletteWindowController sharedToolPaletteController] close];
    }
}

static NSObject<EditorModel>* sEditor=nil;

+ (void)addToWindow:(NSWindow*)parentWindow withEditor:(NSObject<EditorModel>*)editor{
    sEditor=editor;
    
    NSWindow* w=[[ToolPaletteWindowController sharedToolPaletteController] window];
    NSRect pf=[parentWindow frame];
    NSRect wf=[w frame];
    
    float bottom;
    bottom=pf.origin.y+(pf.size.height-wf.size.height);
    if (bottom<0) bottom=0;
    float left=pf.origin.x-wf.size.width-8;
    if (left<0){
        left=0;
        [parentWindow setFrameOrigin:NSMakePoint(wf.size.width+8, wf.origin.y)];
    }
    
    [w setFrameOrigin:NSMakePoint(left, bottom)];

    [parentWindow addChildWindow:w ordered:NSWindowAbove];
    [[ToolPaletteWindowController sharedToolPaletteController] showWindow:self];
};

+ (void)removeFromWindow:(NSWindow*)parentWindow{
    sEditor=nil;
    [parentWindow removeChildWindow:[[ToolPaletteWindowController sharedToolPaletteController] window]];
    [[ToolPaletteWindowController sharedToolPaletteController] close];
};


- (id)initWithWindow:(NSWindow *)window
{
    
    self = [super initWithWindow:window];
    if (self) {
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[matrixTools cellAtRow:kToolArrow column:0] setHighlighted:YES];

 //   [[self window] setLevel:NSDockWindowLevel];
   // [[self window] setLevel:CGWindowLevelForKey(kCGMaximumWindowLevelKey)];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (Tool*) toolSelected:(NSView*)parent {
    //return [toolButtons selectedRow];
  //  static Tool* tool;
/*
    if (nil==tool){
        tool=[[[ToolArrow alloc] init] retain];
    }
 */
//    return [[ToolArrow alloc] init];
    switch (_tool) {
        case kToolText:
            return [[ToolText alloc] init:parent];
            break;
        case kToolRect:
            return [[ToolRect alloc] init:parent];
            break;
        case kToolMark:
            return [[ToolMark alloc] init:parent];
            break;
        default:
            return [[ToolArrow alloc] init:parent];
    }
}

- (CGColorRef)selectedColor{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* stool=[NSString stringWithFormat:@"color%d",_tool];
    NSInteger color=[prefs integerForKey:stool];
    return _colors[color];
}

- (void)selectColor:(int) color{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* stool=[NSString stringWithFormat:@"color%d",_tool];
    [prefs setInteger:color  forKey:stool];
}

- (IBAction)selectColorAction:(id)sender {
    NSMatrix *v=(NSMatrix*)sender;
    NSRect r=v.frame;
    [NSMenu popUpContextMenu:_menuColor
                   withEvent:[NSEvent mouseEventWithType:NSLeftMouseDown
                                                location:NSMakePoint(r.origin.x+58+2,r.origin.y+58*3)
                                           modifierFlags:0 timestamp:1
                                            windowNumber:[[self window] windowNumber]
                                                 context:[NSGraphicsContext currentContext]
                                             eventNumber:1
                                              clickCount:1
                                                pressure:0.0]
                     forView:_menuColorView];
}
- (CGColorRef)colorBlack{
    static CGColorRef color=nil;
    if (!color)
        color=CGColorCreateGenericRGB(0,0,0,1);
    return color;
};
- (CGColorRef)colorBlue{
    static CGColorRef color=nil;
    if (!color)
        color=CGColorCreateGenericRGB(0x1a/256.0,0x34/256.0,0xf3/256.0,1);
    return color;
};
- (CGColorRef)colorGreen{
    static CGColorRef color=nil;
    if (!color)
        color=CGColorCreateGenericRGB(0x6a/256.0,0xf2/256.0,0x37/256.0,1);
    return color;
};
- (CGColorRef)colorOrange{
    static CGColorRef color=nil;
    if (!color)
        color=CGColorCreateGenericRGB(0xed/256.0,0x7f/256.0,0x29/256.0,1);
    return color;

};
- (CGColorRef)colorPurple{
    static CGColorRef color=nil;
    if (!color)
        color=CGColorCreateGenericRGB(0x82/256.0,0x25/256.0,0x80/256.0,1);
    return color;
};
- (CGColorRef)colorRed{
    static CGColorRef color=nil;
    if (!color)
        color=CGColorCreateGenericRGB(0xe5/256.0,0x29/256.0,0x1d/256.0,1);
    return color;
};
- (CGColorRef)colorYellow{
    static CGColorRef color=nil;
    if (!color)
        color=CGColorCreateGenericRGB(0xfd/256.0,0xf7/256.0,0x3f/256.0,1);
    return color;
};
- (CGColorRef)colorWhite{
    static CGColorRef color=nil;
    if (!color)
        color=CGColorCreateGenericRGB(1,1,1,1);
    return color;
};


- (IBAction)selectColorBlackAction:(id)sender {
    [self selectColor: kColorBlack];
    [[NSNotificationCenter defaultCenter] postNotificationName:ColorDidChangeNotification object:self];
}

- (IBAction)selectColorBlueAction:(id)sender{
    [self selectColor: kColorBlue];
    [[NSNotificationCenter defaultCenter] postNotificationName:ColorDidChangeNotification object:self];

};
- (IBAction)selectColorGreenAction:(id)sender {
    [self selectColor: kColorGreen];
    [[NSNotificationCenter defaultCenter] postNotificationName:ColorDidChangeNotification object:self];
};
- (IBAction)selectColorOrangeAction:(id)sender{
    [self selectColor: kColorOrange];
    [[NSNotificationCenter defaultCenter] postNotificationName:ColorDidChangeNotification object:self];
};
- (IBAction)selectColorPurpleAction:(id)sender{
    [self selectColor: kColorPurple];
    [[NSNotificationCenter defaultCenter] postNotificationName:ColorDidChangeNotification object:self];
    
};
- (IBAction)selectColorRedAction:(id)sender{
    [self selectColor: kColorRed];
    [[NSNotificationCenter defaultCenter] postNotificationName:ColorDidChangeNotification object:self];
};
- (IBAction)selectColorYellowAction:(id)sender{
    [self selectColor: kColorYellow];
    [[NSNotificationCenter defaultCenter] postNotificationName:ColorDidChangeNotification object:self];
};
- (IBAction)selectColorWhiteAction:(id)sender{
    [self selectColor: kColorWhite];
    [[NSNotificationCenter defaultCenter] postNotificationName:ColorDidChangeNotification object:self];
};

- (IBAction)selectToolArrowAction:(id)sender{
    _tool=kToolArrow;
    
    //[[matrixTools cellAtRow:kToolArrow column:0] setHighlighted:YES];
    //[[matrixTools cellAtRow:kToolText column:0] setHighlighted:NO];
    //[[matrixTools cellAtRow:kToolRect column:0] setHighlighted:NO];
    //[[matrixTools cellAtRow:kToolMark column:0] setHighlighted:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ToolDidChangeNotification object:self];
};

- (IBAction)selectToolTextAction:(id)sender{
    _tool=kToolText;
    [[matrixTools cellAtRow:kToolArrow column:0] setHighlighted:NO];
    //[[matrixTools cellAtRow:kToolText column:0] setHighlighted:NO];
    //[[matrixTools cellAtRow:kToolRect column:0] setHighlighted:NO];
    //[[matrixTools cellAtRow:kToolMark column:0] setHighlighted:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:ToolDidChangeNotification object:self];
};

- (IBAction)selectToolRectAction:(id)sender{
    _tool=kToolRect;
    [[matrixTools cellAtRow:kToolArrow column:0] setHighlighted:NO];
    //[[matrixTools cellAtRow:kToolText column:0] setHighlighted:NO];
    //[[matrixTools cellAtRow:kToolRect column:0] setHighlighted:NO];
    //[[matrixTools cellAtRow:kToolMark column:0] setHighlighted:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:ToolDidChangeNotification object:self];
};

- (IBAction)selectToolMarkAction:(id)sender{
    _tool=kToolMark;
    [[matrixTools cellAtRow:kToolArrow column:0] setHighlighted:NO];
    //[[matrixTools cellAtRow:kToolText column:0] setHighlighted:NO];
    //[[matrixTools cellAtRow:kToolRect column:0] setHighlighted:NO];
    //[[matrixTools cellAtRow:kToolMark column:0] setHighlighted:NO];

    [[NSNotificationCenter defaultCenter] postNotificationName:ToolDidChangeNotification object:self];
};

- (IBAction)exportToLocal:(id)sender{
    [sEditor exportToLocal];    
};
- (IBAction)exportToCloud:(id)sender{
};
- (IBAction)exportToDropbox:(id)sender{
    [sEditor exportToDropbox];
};
@end
