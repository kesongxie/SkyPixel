//
//  User.m
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "User.h"

@interface User()

@end

@implementation User

- (id)initWithRecord: (CKRecord*) record{
    self = [super init];
    if(self){
        self.record = record;
    }
    return self;
}

-(NSString*) fullname{
    return self.record[FullNameKey];
}

-(NSString*) email{
    return self.record[EmailKey];
}

-(NSURL*) avatorUrl{
    return ((CKAsset*)self.record[AvatorKey]).fileURL;
}

+(void) fetchUserWithReference:(CKReference*) reference completionHandler: (void (^)(CKRecord* userRecord, NSError* error)) callback{
    CKRecordID* recordID = reference.recordID;
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    [db fetchRecordWithID:recordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        callback(record, error);
    }];
}

-(CKReference *)reference{
    return [[CKReference alloc]initWithRecord:self.record action:CKReferenceActionNone];
}

-(UIImage *)thumbImage{
    NSURL* thumbnailURL = self.avatorUrl;
    NSData* imageData = [[NSData alloc]initWithContentsOfURL:thumbnailURL];
    return [[UIImage alloc]initWithData:imageData];
}

@end
