//
//  TextFieldProtocol.h
//  Tinge
//
//  Created by Sergey Dolin on 9/18/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TextFieldProtocol <NSObject>
-(void)updateTextFromField:(NSString*)text;
@end
