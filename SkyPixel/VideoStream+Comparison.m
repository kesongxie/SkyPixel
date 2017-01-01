//
//  VideoStream+Comparison.m
//  SkyPixel
//
//  Created by Xie kesong on 12/31/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import "VideoStream+Comparison.h"

@implementation VideoStream (Comparison)

-(BOOL) isEqual:(id)object{
    if([object isKindOfClass:[VideoStream class]]){
        return [self.record.recordID.recordName isEqualToString:((VideoStream*)object).record.recordID.recordName];
    }
    return NO;
}

@end
