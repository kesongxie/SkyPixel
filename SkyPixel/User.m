//
//  User.m
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "User.h"
#import "VideoStream.h"
#import "CKRecord+Comparison.h"

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

-(NSString*) bio{
    return self.record[BioKey];
}

-(NSString*) email{
    return self.record[EmailKey];
}

-(NSURL*) avatorUrl{
    return ((CKAsset*)self.record[AvatorKey]).fileURL;
}


-(NSURL*) coverUrl{
    return ((CKAsset*)self.record[CoverKey]).fileURL;
}

-(CKReference *)reference{
    return [[CKReference alloc]initWithRecord:self.record action:CKReferenceActionNone];
}

-(UIImage *)thumbImage{
    NSURL *thumbnailURL = self.avatorUrl;
    NSData *imageData = [[NSData alloc]initWithContentsOfURL:thumbnailURL];
    return [[UIImage alloc]initWithData:imageData];
}


-(UIImage *)coverThumbImage{
    NSURL *thumbnailURL = self.coverUrl;
    NSData *imageData = [[NSData alloc]initWithContentsOfURL:thumbnailURL];
    return [[UIImage alloc]initWithData:imageData];
}

-(void)removeVideoStreamRecordFromUser: (CKRecord *)videoStreamRecord{
    [self.videoStreamRecord removeObject:videoStreamRecord];
}

+(void) fetchUserWithReference:(CKReference*) reference completionHandler: (void (^)(CKRecord *userRecord, NSError *error)) callback{
    CKRecordID *recordID = reference.recordID;
    CKDatabase *db = [CKContainer defaultContainer].publicCloudDatabase;
    [db fetchRecordWithID:recordID completionHandler:^(CKRecord  *_Nullable record, NSError  *_Nullable error) {
        callback(record, error);
    }];
}

+(void)loggedIn: (void(^)(User *user, NSError *error)) callback{
    CKDatabase *db = [[CKContainer defaultContainer] publicCloudDatabase];
    NSString *email = @"kesongxie@skypixel.com";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email=%@", email];
    CKQuery *fetchQuery = [[CKQuery alloc]initWithRecordType:@"User" predicate:predicate];
    [db performQuery:fetchQuery inZoneWithID:nil completionHandler:^(NSArray<CKRecord *>  *_Nullable userRecords, NSError  *_Nullable error) {
        if(error != nil){
            NSLog(@"%@", error.localizedDescription);
            callback(nil, error);
        }else{
            if(userRecords.count == 1){
                User *user = [[User alloc]initWithRecord:userRecords.firstObject];
                [VideoStream fetchVideoStreamForUser:user.reference completionHandler:^(NSArray<CKRecord *> *results, NSError *error) {
                    if(error == nil){
                        user.videoStreamRecord = [NSMutableArray arrayWithArray:results];
                        callback(user, nil);
                    }else{
                        callback(nil, error);
                    }
                }];
            }
        }
    }];
}


@end
