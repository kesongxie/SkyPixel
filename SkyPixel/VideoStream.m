//
//  VideoStream.m
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "VideoStream.h"

//keys for columns in the CloudKit database
static NSString* const TitleKey = @"title";
static NSString* const LocationKey = @"location";
static NSString* const VideoKey = @"video";
static NSString* const LiveKey = @"live";
static NSString* const DescriptionKey = @"description";
static NSString* const FavorUserList = @"favorUserList";

@interface VideoStream()

@end

@implementation VideoStream

- (id)initWithCKRecord: (CKRecord*)record{
    self = [super init];
    if(self){
        self.record = record;
    }
    return self;
}

-(void)fetchUserForVideoStream: (void (^)(CKRecord* userRecord, NSError* error)) callBack{
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    CKRecordID* userRecordId = ((CKReference*)self.record[@"user"]).recordID;
    [db fetchRecordWithID:userRecordId completionHandler:^(CKRecord * _Nullable userRecord, NSError * _Nullable error) {
        User* user = [[User alloc]initWithRecord:userRecord];
        self.user = user;
        callBack(userRecord, error);
    }];
}


-(NSString*)title{
    return self.record[TitleKey];
}

-(CLLocation*) location{
    return self.record[LocationKey];
}

-(NSString*) description{
    return self.record[DescriptionKey];
}

-(NSURL*) url{
    return ((CKAsset*)self.record[VideoKey]).fileURL;
}

-(NSArray<CKReference*>*) favorUserList{
    return self.record[FavorUserList];
}

-(BOOL) isLive{
    return ((NSNumber*)self.record[LiveKey]).integerValue == 1;
}


//add a user to the user favor list
-(void)deleteFavorUser: (CKReference*)userReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack{
    //refetch the record
    NSMutableArray<CKReference*>* favorUserList = [NSMutableArray arrayWithArray:self.favorUserList];
    [favorUserList removeObject:userReference];
    [self.record setObject:favorUserList forKey:FavorUserList];
    [self updateRecord:callBack];
    
}

-(void)addFavorUser: (CKReference*)userReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack{
    NSMutableArray<CKReference*>* favorUserList = [NSMutableArray arrayWithArray:self.favorUserList];
    [favorUserList insertObject:userReference atIndex:0];
    [self.record setObject:favorUserList forKey:FavorUserList];
    [self updateRecord:callBack];
}

-(void)updateRecord: (void (^)(CKRecord* videoRecord, NSError* error)) callBack{
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    CKModifyRecordsOperation* updateOperation = [[CKModifyRecordsOperation alloc]init];
    updateOperation.database = db;
    updateOperation.atomic = YES;
    updateOperation.recordsToSave = @[self.record];
    [updateOperation setModifyRecordsCompletionBlock:^(NSArray<CKRecord *> * _Nullable records, NSArray<CKRecordID *> * _Nullable modfiyRecordIDs, NSError * _Nullable error) {
        if(error == nil){
            NSLog(@"record saved %@", records);
            callBack(records.firstObject, error);
        }else{
            callBack(nil, error);
            NSLog(@"the error is %@", error.localizedDescription);
        }
    }];
    NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
    //update record
    [operationQueue addOperation:updateOperation];
}



@end
