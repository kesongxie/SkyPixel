//
//  CKReference+Comparison.m
//  SkyPixel
//
//  Created by Xie kesong on 12/19/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "CKReference+Comparison.h"

@implementation CKReference (Comparison)

-(BOOL) isEqual:(id)object{
    if([object isKindOfClass:[CKReference class]]){
        return [self.recordID.recordName isEqualToString:((CKReference*)object).recordID.recordName];
    }
    return NO;
}
@end
