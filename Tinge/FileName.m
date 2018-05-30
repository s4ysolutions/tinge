//
//  FileName.m
//  Tinge
//
//  Created by Sergey Dolin on 8/16/16.
//  Copyright (c) 2016 S4Y. All rights reserved.
//

#import "FileName.h"

@implementation FileName
+(NSString*)stringNowWith:(NSString*)suffix{
    static NSDateFormatter *dateFormatter;

    if (dateFormatter==nil){
        /*
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMM" options:0
                                                                  locale:[NSLocale currentLocale]];*/
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    
    
    NSCalendar* cal=[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components=[cal components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];

    int h=(int)[components hour] ;
    int m=(int)[components minute] ;
    int s=(int)[components second];

    [cal release];
    NSString *todayString = [NSString stringWithFormat:@"%@_%d%@",[dateFormatter stringFromDate:[NSDate date]],(3600*h+60*m+s)/10,suffix];
    
    return todayString;
};
@end
