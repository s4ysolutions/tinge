//
//  EditorWindowController.m
//  Tinge
//
//  Created by Sergey Dolin on 8/17/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//
#import "EditorWindowController.h"
#import "PresentationManager.h"
#import "ToolPaletteWindowController.h"
#import "FileName.h"
#import "UploadWindowController.h"
#import "DropboxUploadStorage.h"
#import "Pasteboard.h"

@interface EditorWindowController (){
@private
    NSMutableArray *_tools;
    Tool* _activeTool;
    Tool* _pastedTool;
    CGImageRef _image;
    NSUndoManager* _undoManager;
}

@end

@implementation EditorWindowController

+ (NSMutableArray*)controllers{
    static NSMutableArray* editorWindowControllers=nil;
    if (nil==editorWindowControllers){
        editorWindowControllers=[[NSMutableArray alloc] initWithCapacity:3];
    };
    return editorWindowControllers;
}

+(EditorWindowController*)startEdit:(CGImageRef)image
{
    EditorWindowController* ewc=[[EditorWindowController alloc ] initWithImageRef:image];
    if (ewc){
        [ewc showWindow:self];
    }
    return ewc;
}

- (EditorWindowController*)initWithImageRef:(CGImageRef)image {
    self = [super initWithWindowNibName:@"Editor"];
    if (self) {
        [self setWindowFrameAutosaveName:@"Editor"];
        _image=image;
        CGImageRetain(_image);
        _tools=[[NSMutableArray alloc] init];
        [[EditorWindowController controllers] addObject:self];
        _undoManager=[[NSUndoManager alloc] init];
    }
    return self;
};

- (void)dealloc {
    CGImageRelease(_image);
    [_tools release];
    [_pastedTool release];
    [_undoManager release];
    [super dealloc];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    NSSize newSize = NSSizeFromCGSize([self imageSize]);
    [imageView setFrameSize:newSize];
    if (newSize.width<100) newSize.width=100;
    if (newSize.height<50) newSize.height=50;
    [self.window setContentSize:newSize];
    //[self.window setContentMaxSize:newSize];
    [self.window setTitle:[FileName stringNowWith:@".png"]];
    [self.window setAcceptsMouseMovedEvents:YES];
}

- (IBAction)showWindow:(id)sender
{
    [PresentationManager editorDidOpen];
    [super showWindow:sender];
}


#pragma mark *** EditorModel Protocol ***
- (void) drawInContext:(CGContextRef)context{
    if (context==nil)
        return;
    
    if (_image==nil)
        return;
    
    CGRect imageRect = {{0,0}, [self imageSize]};
    
    CGInterpolationQuality q = NSImageInterpolationHigh;
    CGContextSetInterpolationQuality(context, q);
    
    CGContextDrawImage(context, imageRect, _image);
    
    for (int i=0;i<[_tools count];i++){
        [[_tools objectAtIndex:i] draw:context];
    }
};

- (void) undoModified:(NSArray*)tools{
//    [self addEditedToolWithUndo:[tools objectAtIndex:0] original:[tools objectAtIndex:1]];
    Tool* modifiedAsOriginal=nil;
    Tool* modified=[tools objectAtIndex:0];
    Tool* original=[tools objectAtIndex:1];
    for (NSInteger i=0;i<_tools.count;i++){
        if (modified==[_tools objectAtIndex:i]){
            modifiedAsOriginal=[[_tools objectAtIndex:i] copy];
            [[_tools objectAtIndex:i] copyFrom:original];
           [_undoManager registerUndoWithTarget:self selector:@selector(undoModified:) object:[NSArray arrayWithObjects:modified,modifiedAsOriginal, nil]];
            [imageView setNeedsDisplay:YES];
            [imageView setupCursor];
            break;
        }
    }
    
}

- (void) addEditedToolWithUndo:(Tool*)modified original:(Tool*)original{
    //NSInteger tooli=-1;
    [modified show];
    [original hide];
    [_undoManager registerUndoWithTarget:self selector:@selector(undoModified:) object:[NSArray arrayWithObjects:modified,original, nil]];

    
    /*
    if (tooli<0) { //modifed not found ergo UNDO
        for (NSInteger i=0;i<_tools.count;i++){
            if (original==[_tools objectAtIndex:i]){
                NSLog(@"Will replace");
                [[_tools objectAtIndex:i] copyFrom:original];
//                [_tools setObject:modified atIndexedSubscript:i];
                break;
            }
        }
        [imageView setNeedsDisplay:YES];
        [imageView setupCursor];
    }else{
        NSLog(@"Will not replace");
    };
    {
        [_undoManager registerUndoWithTarget:self selector:@selector(addEditedAndOriginalToolsWithUndo:) object:[NSArray arrayWithObjects:original,modified, nil]];
    }
    NSLog(@"_tools 1: %@",_tools);*/

};

- (void) addOrRemoveToolWithUndo:(Tool*) tool{
    NSInteger tooli=-1;
    
    for (NSInteger i=0;i<_tools.count;i++){
        if (tool==[_tools objectAtIndex:i]){
            tooli=i;
            break;
        }
    }
    if (tooli>=0) {
        [_tools removeObjectAtIndex:tooli];
        [tool hide];
        [self deactiviteAllTools];
    } else {
        [_tools addObject:tool];
        [tool show];
        [tool added];
        //[self activateTool:tool];
    }

    [_undoManager registerUndoWithTarget:self selector:@selector(addOrRemoveToolWithUndo:) object:tool];
    [imageView setNeedsDisplay:YES];
    [imageView setupCursor];
}

- (Tool*) toolByPointAtEnd:(CGPoint)point{
    for (NSInteger i=_tools.count-1;i>=0;i--){
        Tool* t=[_tools objectAtIndex:i];
        if ([t endContainsPoint:point]){
            return t;
        }
    }
    return nil;
};

- (Tool*) toolByPointAtBegin:(CGPoint)point{
    for (NSInteger i=_tools.count-1;i>=0;i--){
        Tool* t=[_tools objectAtIndex:i];
        if ([t beginContainsPoint:point]){
            return t;
        }
    }
    return nil;
};

- (Tool*) activeTool{
    return _activeTool;
};

- (BOOL) deactivateTool:(Tool*) tool{
    BOOL ret=_activeTool || tool.active;
    _activeTool=nil;
    tool.active=NO;
    return ret;
}

- (BOOL) activateTool:(Tool*) tool{
    BOOL ret=!!_activeTool;
    _activeTool.active=NO;

    NSInteger tooli=-1;
    
    for (NSInteger i=0;i<_tools.count;i++){
        if (tool==[_tools objectAtIndex:i]){
            tooli=i;
            break;
        }
    }
    if (tooli>=0) {
        [_tools removeObjectAtIndex:tooli];
        [_tools addObject:tool];
    }

    _activeTool=tool;
    tool.active=YES;
    return ret;
}


- (Tool*) toolByPoint:(CGPoint) point {
    for (NSInteger i=_tools.count-1;i>=0;i--){
        Tool* t=[_tools objectAtIndex:i];
        if ([t containsPoint:point]){
            //           [self activateTool:t];
            return t;
        }
    }
    return nil;
};

- (BOOL) activateToolByPoint:(CGPoint) point {
    Tool* t=[self toolByPoint:point];
    if (t){
        return [self activateTool:t];
    }
    return !!_activeTool;
    /*
    BOOL ret=NO;
    Tool* activeTool=nil;
    for (NSInteger i=_tools.count-1;i>=0;i--){
        Tool* t=[_tools objectAtIndex:i];
        if ([t containsPoint:point]){
//           [self activateTool:t];
            activeTool=t;
            break;
        }else{
            BOOL  r=[self deactivateTool:t];
            ret = ret || r;
        }
    }
    if (activeTool){
        BOOL r = [self activateTool:activeTool];
        ret=ret || r;
    }
    return ret;
     */
};

- (void) checkActiveTool {
    if (!_activeTool) return;
    for (NSInteger i=_tools.count-1;i>=0;i--){
        Tool* t=[_tools objectAtIndex:i];
        if (t==_activeTool)
            return;
    }
    _activeTool=nil;
};

- (void) deactiviteAllTools {
    for (NSInteger i=_tools.count-1;i>=0;i--){
        Tool* t=[_tools objectAtIndex:i];
        [self deactivateTool:t];
    }
};

- (void) removeTool:(Tool*) tool{
    for (NSInteger i=_tools.count-1;i>=0;i--){
        Tool* t=[_tools objectAtIndex:i];
        if (tool==t){
            [self addOrRemoveToolWithUndo:tool];
            break;
        }
    }
};

- (void) removeActiveTool{
    if (_activeTool){
        [self addOrRemoveToolWithUndo:_activeTool];
    }
};

- (Tool*) pastedTool{
    return _pastedTool;
};

- (void) copyActiveTool{
    [_pastedTool release];
    _pastedTool=[_activeTool copy];
};


- (CGSize)imageSize
{
    if (_image)
    {
        return CGSizeMake(CGImageGetWidth(_image), CGImageGetHeight(_image));
    }
    
    return CGSizeMake(0, 0);
}

- (void) receiveDeleteNotification:(NSNotification *) notification
{
    [self removeTool:notification.object];
}

#pragma mark *** EditorModel Protocol - Export ***

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL status = NO;
    CGImageDestinationRef dest = nil;
    
    /* Create a new CFStringRef containing a uniform type identifier (UTI) that is the equivalent
     of the passed file extension. */
    CFStringRef utiRef = UTTypeCreatePreferredIdentifierForTag(
                                                               kUTTagClassFilenameExtension,
                                                               (__bridge CFStringRef) typeName,
                                                               kUTTypeData
                                                               );
    if (utiRef==nil)
    {
        goto bail;
    }
    
    /* Create an image destination writing to absoluteURL. */
    dest = CGImageDestinationCreateWithURL((__bridge CFURLRef)absoluteURL, utiRef, 1, nil);
    CFRelease(utiRef);
    
    if (dest==nil)
    {
        goto bail;
    }
    
    
    if (_image==nil)
    {
        goto bail;
    }
    /*
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, CGImageGetWidth(_image),CGImageGetHeight(_image), 8, 0, colorSpace,(CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    [self drawInContext:context];
    
    CGImageRef drawnImage=CGBitmapContextCreateImage(context);
     */
    
    /*
    NSBitmapImageRep * bm = [NSBitmapImageRep alloc];
    [imageView lockFocus];
    [bm initWithFocusedViewRect:[imageView bounds]];
    //[imageView cacheDisplayInRect:[imageView bounds] toBitmapImageRep:bm];
    [imageView unlockFocus];
    */
    
    //[imageView lockFocus];
    [self deactiviteAllTools];
    NSBitmapImageRep * bm = [imageView bitmapImageRepForCachingDisplayInRect:imageView.bounds];
    [imageView cacheDisplayInRect:imageView.bounds toBitmapImageRep:bm];
    //[imageView unlockFocus];
    
    NSInteger     rowBytes, width, height;
    
    rowBytes = [bm bytesPerRow];
    width = [bm pixelsWide];
    height = [bm pixelsHigh];
    CGDataProviderRef provider = CGDataProviderCreateWithData( bm, [bm bitmapData], rowBytes * height, NULL );
    CGColorSpaceRef colorspace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB );
    CGBitmapInfo    bitsInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedLast;
    
    CGImageRef drawnImage = CGImageCreate( width, height, 8, 32, rowBytes, colorspace, bitsInfo, provider, NULL, NO, kCGRenderingIntentDefault );

    CGImageDestinationAddImage(dest, drawnImage, NULL);
    
    status = CGImageDestinationFinalize(dest);
//    CGContextRelease (context);
    CGDataProviderRelease( provider );
    CGColorSpaceRelease(colorspace);
    CGImageRelease(drawnImage);
    //[bm release];

bail:
    if (dest)
    {
        CFRelease(dest);
    }
    return status;
}

- (IBAction) exportToLocal:(id)sender {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    /* The supported file types for the save operation. */
    NSArray *fileTypes = [NSArray arrayWithObjects:@"png",@"jpg",@"jpeg",@"tiff",@"bmp",nil];
    [savePanel setAllowedFileTypes:fileTypes];
    [savePanel setExtensionHidden:NO];
    /* Default save file name. */
    [savePanel setNameFieldStringValue:[self.window title]];
    
    [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result)
     {
         if (NSFileHandlingPanelOKButton == result)
         {
             NSURL *URL = [savePanel URL];
             [self.window setTitle:[[URL pathComponents] lastObject]];
             NSString *pathExtension = [URL pathExtension];
             if (YES==[pathExtension isEqualToString:@""])
             {
                 pathExtension = @"png";
                 URL = [URL URLByAppendingPathExtension:pathExtension];
             }
             
             NSError *err = nil;
             BOOL success = [self writeToURL:URL ofType:pathExtension error:&err];
             if (!success)
             {
                 NSLog(@"writeToURL (%@) Error %@",[URL path],[err localizedDescription]);
                 
             }
             else
             {
                 [Pasteboard pasteString:[URL path]];
                 [self close];
             }
         }
     }];
};

- (void) exportToLocal{
    [self exportToLocal:self];
}
/*
- (BOOL) exportFileToDropbox:(NSURL*)url {
    BOOL repeat;
    BOOL cancel;
    [UploadWindowController uploadFile:url withImage:_image toStorage:[DropboxUploadStorage storageWithFileURL:url] canceled:&cancel mayNeedRepeat:&repeat];
    [UploadWindowController uploadFile:url withImage:_image toStorage:[DropboxUploadStorage storageWithFileURL:url] canceled:&cancel mayNeedRepeat:&repeat];
    return cancel || !repeat;
}
*/
- (IBAction) exportToDropbox:(id)sender {
    NSURL *url=[NSURL URLWithString: [NSString stringWithFormat:@"file://localhost/tmp/%@",[self.window title] ]];
    NSError *err = nil;
    BOOL success = [self writeToURL:url ofType:[url pathExtension] error:&err];
    if (!success)
    {
        NSLog(@"exportToDropbox, write temp file(%@): %@",[url path],[err localizedDescription]);
        
    }
    else
    {
        BOOL success=[UploadWindowController startUploadFile:url withImage:_image toStorage:[DropboxUploadStorage storageWithFileURL:url]];
        if (success)
            [self close];
    }
}

- (void) exportToDropbox{
    [self exportToDropbox:self];
}
/*
- (void) reexport{
    [self exportToDropbox:self];
}*/

#pragma mark *** Key handling ***




#pragma mark *** NSWindowDelegate Protocoal ***
- (void)windowWillClose:(NSNotification *)notification{
    [[EditorWindowController controllers] removeObject:self];
    [PresentationManager editorDidClose];
//    [ToolPaletteWindowController hide];
    [self autorelease];
}

- (void)selectedToolDidChange:(NSNotification *)notification {
}

- (void)selectedColorDidChange:(NSNotification *)notification {
    Tool* t=nil;
    if (_activeTool){
        t=_activeTool;
        // you need to change color without affecting the recnt rtool
//    }else if (_tools.count>0) {
//        t=(Tool*)[_tools lastObject];
    }
    if (t){
        CGColorRef c=[[ToolPaletteWindowController sharedToolPaletteController] selectedColor];
        if (!CGColorEqualToColor(c,t.color)){
            Tool* t0=[t copy];
            [t setColor:c];
            [self addEditedToolWithUndo:t original:t0];
            [t0 release];
            [imageView setNeedsDisplay:YES];
        }
    }
}

- (void)windowDidBecomeKey:(NSNotification *)notification{
    [ToolPaletteWindowController addToWindow:self.window withEditor:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedToolDidChange:) name:ToolDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedColorDidChange:) name:ColorDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteNotification:) name:ToolShouldBeDeletedNotification object:nil];


//    [self.window addChildWindow:[[ToolPaletteWindowController sharedToolPaletteController] window] ordered:NSWindowAbove];
}

- (void)windowDidResignKey:(NSNotification *)notification {
    [ToolPaletteWindowController removeFromWindow:self.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ToolDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ColorDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ToolShouldBeDeletedNotification object:nil];

//    [self.window removeChildWindow:[[ToolPaletteWindowController sharedToolPaletteController] window]];
}

/*
- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
    if (item.tag==1 || item.tag==2) {
        return YES;
    }
    return [super validateUserInterfaceItem:item];
}*/

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender
{
    return _undoManager;
}

@end
