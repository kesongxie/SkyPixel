//
//  PrettyDateFormatter.m
//  SkyPixel
//
//  Created by Xie kesong on 12/20/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "PrettyDateFormatter.h"

@interface PrettyDateFormatter()

@end


@implementation PrettyDateFormatter

+(NSString*)agoFormatterFromDate: (NSDate*) date{
    NSTimeInterval ellapseTime = -[date timeIntervalSinceNow];
    NSInteger ellapseTimeSeconds = [NSNumber numberWithDouble:ellapseTime].integerValue;
    NSString* output = @"";
    if(ellapseTimeSeconds < 15){
        output = [NSString stringWithFormat:@"Just Now"];
    }else if(ellapseTimeSeconds < 60){
        output = [NSString stringWithFormat:@"%is", ellapseTimeSeconds];
    }else if(ellapseTimeSeconds < 60 * 60){
        output = [NSString stringWithFormat:@"%im", ellapseTimeSeconds / 60];
    }else if(ellapseTimeSeconds < 60 * 60 * 24){
        output = [NSString stringWithFormat:@"%ih", ellapseTimeSeconds / 3600];
    }else if(ellapseTimeSeconds < 60 * 60 * 24 * 7){
        output = [NSString stringWithFormat:@"%id", ellapseTimeSeconds /(3600*24)];
    }else{
        output = [NSString stringWithFormat:@"%iweek", ellapseTimeSeconds /(3600*24*7)];
    }
    return output;
}

@end
