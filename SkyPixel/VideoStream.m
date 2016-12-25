//
//  VideoStream.m
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "VideoStream.h"
#import "VideoAsset.h"

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
    CKReference* userReference = ((CKReference*)self.record[UserReferenceKey]);
    CKRecordID* userRecordId = userReference.recordID;
    [db fetchRecordWithID:userRecordId completionHandler:^(CKRecord * _Nullable userRecord, NSError * _Nullable error) {
        User* user = [[User alloc]initWithRecord:userRecord];
        self.user = user;
        //fetch some video stream for the user
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", UserReferenceKey, userReference];
        CKQuery* query = [[CKQuery alloc]initWithRecordType:VideoStreamRecordType predicate:predicate];
        [db performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
            if(error == nil){
                callBack(userRecord, error);
                self.user.videoStreamRecord = results;
            }else{
                callBack(nil, error);
            }
        }];
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

-(CKReference *)userReference{
    return self.record[UserReferenceKey];
}

-(NSURL *)thumbnail{
    CKAsset* asset = self.record[ThumbnailListKey];
    return asset.fileURL;
}

-(BOOL) isLive{
    return ((NSNumber*)self.record[LiveKey]).integerValue == 1;
}

-(CGFloat)width{
     return ((NSNumber*)self.record[WidthKey]).floatValue;
}

-(CGFloat)height{
    return ((NSNumber*)self.record[HeightKey]).floatValue;
}

-(UIImage *)thumbImage{
    NSURL* thumbnailURL = self.thumbnail;
    NSData* imageData = [[NSData alloc]initWithContentsOfURL:thumbnailURL];
    return [[UIImage alloc]initWithData:imageData];
}

-(void)loadVideoAsset: (void(^)(CKAsset* videoAsset, NSError *error)) callback{
        [VideoAsset loadAssetForVideoStreamReference:self.reference completionHandler:^(NSArray<CKRecord *> *results, NSError *error) {
        if(error == nil){
            CKRecord* assetRecord = results.firstObject;
            callback(assetRecord[AssetKey], nil);
        }else{
            callback(nil, error);
        }
    }];
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
            NSLog(@"the error is %@", error.localizedDescription);
            //try again
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

//add a user to the user favor list
-(void)deleteComment: (CKReference*)commentReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack{
    //refetch the record
    NSMutableArray<CKReference*>* commentReferenceList = [NSMutableArray arrayWithArray:self.commentReferenceList];
    [commentReferenceList removeObject:commentReference];
    [self.record setObject:commentReferenceList forKey:CommentListKey];
    [self updateRecord:callBack];
}

+(void)fetchVideoStreamForUser:(CKReference*)userReference completionHandler:(void(^)(NSArray<CKRecord*>* results, NSError* error)) callback{
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    NSString* userColumn = UserReferenceKey;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", userColumn,userReference];
    CKQuery* query = [[CKQuery alloc]initWithRecordType:VideoStreamRecordType predicate:predicate];
    [db performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if(error == nil){
            callback(results, nil);
        }else{
            NSLog(@"Error %@", error.localizedDescription);
        }
    }];
}



+(void)fetchLive: (CLLocation*)location withRadius: (CGFloat)searchRadius completionHandler:(void(^)(NSMutableArray<VideoStream*>* videoStreams, NSError* error)) callback{
    CKDatabase* publicDB = [[CKContainer defaultContainer] publicCloudDatabase];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"distanceToLocation:fromLocation:(location, %@) < %f",location, searchRadius];
    CKQuery* query = [[CKQuery alloc] initWithRecordType:VideoStreamRecordType predicate: predicate];
    [publicDB performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord*>* videoStreamRecords, NSError* error){
        if(error == nil){
            if(videoStreamRecords){
                NSLog(@"record is ready");
//                __block NSInteger userFetchedCompletedCount = 0;
                NSMutableArray<VideoStream*>* resultVideoStream = [[NSMutableArray alloc]init];
                for(CKRecord* streamRecord in videoStreamRecords){
                    VideoStream* videoStream = [[VideoStream alloc]initWithCKRecord:streamRecord];
                    [videoStream fetchUserForVideoStream:^(CKRecord *userRecord, NSError *error) {
                        if(error == nil){
                            User* user = [[User alloc]initWithRecord:userRecord];
                            videoStream.user = user;
                            [resultVideoStream insertObject:videoStream atIndex:0];
                            if(resultVideoStream.count == videoStreamRecords.count){
                                //finished fetching
                                callback(resultVideoStream, error);
                            }
                        }else{
                             NSLog(@"%@", error.localizedDescription);
                        }
                    }];
                }
            }
        }else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];

}



@end
