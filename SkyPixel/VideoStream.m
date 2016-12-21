//
//  VideoStream.m
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "VideoStream.h"



@interface VideoStream()

@end

@implementation VideoStream

@synthesize commentReferenceList = _commentReferenceList;

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

-(NSMutableArray<CKReference*>*) favorUserList{
    return self.record[FavorUserListKey];
}


-(NSMutableArray<CKReference*>*) commentReferenceList{
    return self.record[CommentListKey];
}

-(void)setCommentReferenceList:(NSMutableArray<CKReference *> *)commentReferenceList{
    self.record[CommentListKey] = commentReferenceList;
}


-(CKReference *)reference{
    return [[CKReference alloc]initWithRecord:self.record action:CKReferenceActionNone];
}




-(BOOL) isLive{
    return ((NSNumber*)self.record[LiveKey]).integerValue == 1;
}

//add a user to the user favor list
-(void)deleteFavorUser: (CKReference*)userReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack{
    //refetch the record
    NSMutableArray<CKReference*>* favorUserList = [NSMutableArray arrayWithArray:self.favorUserList];
    [favorUserList removeObject:userReference];
    [self.record setObject:favorUserList forKey:FavorUserListKey];
    [self updateRecord:callBack];
}

-(void)addFavorUser: (CKReference*)userReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack{
    NSMutableArray<CKReference*>* favorUserList = [NSMutableArray arrayWithArray:self.favorUserList];
    [favorUserList insertObject:userReference atIndex:0];
    [self.record setObject:favorUserList forKey:FavorUserListKey];
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


//this function adds a new comment reference to the commentList ckreference list
-(void)addCommentReference: (CKReference*)commentReference completionHandler: (void(^)(NSArray<CKRecord*>* records, NSArray<CKRecordID*>* recordIDs, NSError* error)) callback{
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    if(self.commentReferenceList == nil){
        NSMutableArray<CKReference*>* newReferenceArray = [[NSMutableArray alloc]init];
        [newReferenceArray insertObject:commentReference atIndex:0];
        self.record[CommentListKey] = newReferenceArray;
    }else{
        [self.commentReferenceList insertObject:commentReference atIndex:0];
    }
    
    [self.record setObject:self.commentReferenceList forKey: CommentListKey];
    CKModifyRecordsOperation* addCommentOperation = [[CKModifyRecordsOperation alloc]init];
    addCommentOperation.database = db;
    addCommentOperation.atomic = YES;
    addCommentOperation.recordsToSave = @[self.record];
    [addCommentOperation setModifyRecordsCompletionBlock:^(NSArray<CKRecord *> * _Nullable records, NSArray<CKRecordID *> * _Nullable recordIDs, NSError * _Nullable error) {
        if(error == nil){
            if(callback){
                callback(records, recordIDs, error);
            }
        }else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperation:addCommentOperation];
}


@end
