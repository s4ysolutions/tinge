//
//  Pasteboard.m
//  Tinge
//
//  Created by Sergey Dolin on 8/19/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Pasteboard.h"

@implementation Pasteboard
#pragma mark Pasteboard
+(void)pasteString:(NSString*) string{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    //    [pasteboard clearContents];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteboard setString:string forType:NSStringPboardType];
}

+(void)pasteImage:(CGImageRef)image pointSize:(NSSize)size {
  if (image != nil) {
    /* size is in points; the CGImage holds the pixels, so pasted images keep the on-screen size. */
    NSImage *nsImage = [[NSImage alloc] initWithCGImage:image size:size];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSArray *copiedObjects = [NSArray arrayWithObject:nsImage];
    [pasteboard writeObjects:copiedObjects];
    [nsImage release];
  }
}

@end
