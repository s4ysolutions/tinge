//
//  ImageDocument.m
//  Tinge
//
//  Created by Sergey Dolin on 6/5/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "ImageDocument.h"
#import "ImageView.h"
#import "PresentationManager.h"
#import "ToolPaletteWindowController.h"
#import "FileName.h"

NSString * const ImageDocName = @"ImageDocument";

@implementation ImageDocument {
    @private
    NSMutableArray *_tools;
}

//@synthesize tools=_tools;

#pragma mark NSDocument overrides

- (id)initWithType:(NSString *)typeName error:(NSError **)outError
{
    self = [super init];
    if (self)
    {
        image = nil;
        _tools=[[NSMutableArray alloc] init];

        /* Mark document contents as initially overwritten, so if the document is closed the user
         will be prompted to save. */
        [self updateChangeCount:NSSaveOperation];
    }
    
    return self;
}

- (void)dealloc {
    [_tools release];
    [super dealloc];
}

/* Returns the name of the nib file that stores the window associated with the receiver. */
- (NSString *)windowNibName
{
    return ImageDocName;
}

/* Writes the contents of the document to a file or file package located by a URL, formatted to a specified type. */
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
    
    /* The image snapshot associated with the document. */
    CGImageRef docImage = [self currentCGImage];
    
    
    if (docImage==nil)
    {
        goto bail;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, CGImageGetWidth(image),CGImageGetHeight(image), 8, 0, colorSpace,(CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    [self drawIn:context];
    /* Set the image in the image destination to be our document image snapshot. */
    
    CGImageRef drawnImage=CGBitmapContextCreateImage(context);
    
    CGImageDestinationAddImage(dest, drawnImage, NULL);
    
    /* Writes image data to the URL associated with the image destination. */
    status = CGImageDestinationFinalize(dest);
    CGContextRelease (context);
    CGColorSpaceRelease(colorSpace);
    
bail:
    if (dest)
    {
        CFRelease(dest);
    }
    return status;
}


- (void) drawIn:(CGContextRef)context{
    if (context==nil)
        return;
    
    if (image==nil)
        return;
    
    CGRect imageRect = {{0,0}, {CGImageGetWidth(image),CGImageGetHeight(image)}};
    
    CGInterpolationQuality q = NSImageInterpolationHigh;
    CGContextSetInterpolationQuality(context, q);
    
    CGContextDrawImage(context, imageRect, image);
    
    for (int i=0;i<[_tools count];i++){
        [[_tools objectAtIndex:i] draw:context];
    }
};


- (BOOL)saveToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError
{
    NSString *docTypeName = [absoluteURL pathExtension];
    /* Was an extension specified? */
    if ([docTypeName isEqualToString:@""])
    {
        /* No extension, so use jpeg. */
        docTypeName = @"png";
        return ([self writeToURL:[absoluteURL URLByAppendingPathExtension:docTypeName] ofType:docTypeName error:outError]);
    }
    
    return ([self writeToURL:absoluteURL ofType:docTypeName error:outError]);
}

/* Present the save panel to allow the user to save the document window contents to
 an image file on disk. */
-(void)doSaveDocument:(NSSaveOperationType)saveOperation
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    /* The supported file types for the save operation. */
    NSArray *fileTypes = [self writableTypesForSaveOperation:saveOperation];
    [savePanel setAllowedFileTypes:fileTypes];
    [savePanel setExtensionHidden:NO];
    /* Default save file name. */
    [savePanel setNameFieldStringValue:[FileName stringNowWith:@".png"]];
    
    /* Run the save dialog. */
    [savePanel beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result)
     {
         /* User pressed OK button? */
         if (NSFileHandlingPanelOKButton == result)
         {
             NSURL *URL = [savePanel URL];
             NSString *pathExtension = [URL pathExtension];
             /* Use .png file extension if none was specified. */
             if (YES==[pathExtension isEqualToString:@""])
             {
                 pathExtension = @"png";
                 URL = [URL URLByAppendingPathExtension:pathExtension];
             }
             
             NSError *err = nil;
             /* Write the image file to disk. */
             BOOL success = [self writeToURL:URL ofType:pathExtension error:&err];
             /* Error? */
             if (!success)
             {
                 NSLog(@"%@",[err localizedDescription]);
             }
             else
             {
                 NSArray *winControllers = [self windowControllers];
                 /* Set window title to saved filename. */
                 [[[winControllers objectAtIndex:0] window] setTitle:[savePanel nameFieldStringValue]];
                 
                 [self updateChangeCount:NSChangeCleared];
             }
         }
     }];
}

/* Called when the File->Save menu item is selected for the document. */
- (IBAction)saveDocument:(id)sender
{
    [self doSaveDocument:NSSaveOperation];
}

/* Called when the File->Save As menu item is selected for the document. */
/*
- (IBAction)saveDocumentAs:(id)sender
{
    [self doSaveDocument:NSSaveAsOperation];
}

*/
/*
 Validates the specified user interface items.
 (NOTE: The File Owner's delegate must be set in IB in order for this method to be called)
 */
- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
    SEL action = [item action];
    
    if (action == @selector(saveDocument:) && !([self isDocumentEdited]))
    {
        return NO;
    }
    else
    {
        return YES;
    }
    
    if (action == @selector(saveDocumentAs:))// || action == @selector(pageSetup:))
    {
        return YES;
    }
    
    return [super validateUserInterfaceItem:item];
}


#pragma mark Document Display

/* The image associated with and displayed in the document. */
- (CGImageRef)currentCGImage
{
    return image;
}

/* Ster for document image.*/
-(void)setCGImage:(CGImageRef)anImage
{
    if (image)
    {
        CFRelease(image);
    }
    
    /* Save new image. */
    image = (CGImageRef)CFRetain(anImage);
    
    /* Resize the image view. */
    CGSize imageSize = CGSizeMake (
                                   CGImageGetWidth(anImage),
                                   CGImageGetHeight(anImage)
                                   );
    NSSize newSize = NSSizeFromCGSize(imageSize);
    [imageView setFrameSize:newSize];
    //[scrollView.documentView setContentSize:newSize];
    if (newSize.width<100) newSize.width=100;
    if (newSize.height<50) newSize.height=50;
    [imageView.window setContentSize:newSize];
    [imageView.window setContentMaxSize:newSize];
    
    /* Mark image view as needing display. */
    [imageView setNeedsDisplay:YES];
    /*
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];*/
    
}

/* Getter for image size. */
- (CGSize)imageSize
{
    if (image)
    {
        return CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    }
    
    return CGSizeMake(0, 0);
}

- (void)selectedToolDidChange:(NSNotification *)notification {
    // Just set the correct cursor
    /*
    Class theClass = [[SKTToolPaletteController sharedToolPaletteController] currentGraphicClass];
    NSCursor *theCursor = nil;
    if (theClass) {
        theCursor = [theClass creationCursor];
    }
    if (!theCursor) {
        theCursor = [NSCursor arrowCursor];
    }
    [[_graphicView enclosingScrollView] setDocumentCursor:theCursor];
     */
}


- (void) addTool:(Tool*) tool{
    if ([_tools lastObject]==tool)
        [_tools removeLastObject];
    else
        [_tools addObject:tool];
    [[self undoManager] registerUndoWithTarget:self selector:@selector(addTool:) object:tool];
    [imageView setNeedsDisplay:YES];
    //TODO: redo all after save 
    [self updateChangeCount:NSSaveOperation];
}

#pragma mark window controller

- (void)windowControllerDidLoadNib:(NSWindowController *) controller
{
    [super windowControllerDidLoadNib:controller];
//    [[controller window] toggleFullScreen: self];
   // [[controller window] setFrame:[[NSScreen mainScreen] visibleFrame]];
    // Add any code here that need to be executed once the
    //windowController has loaded the document's window.
    
    // snip (this method is never called)
}
#pragma mark window delegate
- (void)windowWillClose:(NSNotification *)notification {
//    [PresentationManager documentWillBeClosed];
  //  [ToolPaletteWindowController hide];
  //  [PresentationManager toBackground];

//    ProcessSerialNumber psn = { 0, kCurrentProcess };
  //  TransformProcessType(&psn, kProcessTransformToUIElementApplication);

//     [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
}


- (void)windowDidBecomeKey:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedToolDidChange:) name:ToolDidChangeNotification object:nil];
}

- (void)windowDidResignKey:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ToolDidChangeNotification object:nil];
}

@end
