//
//  Comment.h
//  SkyPixel
//
//  Created by Xie kesong on 12/19/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "User.h"

@interface Comment : NSObject

@property (strong, nonatomic) CKRecord* record;
@property (strong, nonatomic) CKRecord* userRecord;
//compute from the record class
@property (strong, readonly, nonatomic) NSString* createdDate;
@property (strong, readonly, nonatomic) NSString* text;
@property (strong, readonly, nonatomic) NSString* fullname;
@property (strong, readonly, nonatomic) NSURL* avatorURL;


- (id)initWithRecord: (CKRecord*) record WithUserRecord: (CKRecord*) userRecord;

@end

