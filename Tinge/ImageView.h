//
//  ImageView.h
//  Tinge
//
//  Created by Sergey Dolin on 6/5/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EditorModel.h"

#define SIGNIFICANT_MOVE 10


@interface ImageView : NSView{
@private
    IBOutlet NSObject<EditorModel>* editorModel;
}
-(void)setupCursor;
- (void)delete:(id)sender;
@end
