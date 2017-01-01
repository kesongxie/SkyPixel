//
//  CKRecord+Comparison.h
//  SkyPixel
//
//  Created by Xie kesong on 12/31/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <CloudKit/CloudKit.h>

@interface CKRecord (Comparison)

-(BOOL) isEqual:(id)object;

@end
