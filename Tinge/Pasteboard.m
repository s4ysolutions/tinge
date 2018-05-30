//
//  Pasteboard.m
//  Tinge
//
//  Created by Sergey Dolin on 8/19/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "Pasteboard.h"

@implementation Pasteboard
#pragma mark Pasteboard
+(void)pasteString:(NSString*) string{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    //    [pasteboard clearContents];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteboard setString:string forType:NSStringPboardType];
}
@end
