//
//  Comment.m
//  SkyPixel
//
//  Created by Xie kesong on 12/19/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "Comment.h"
#import "AppDelegate.h"
#import "PrettyDateFormatter.h"

static NSString* const TextKey = @"text";
static NSString* const CreatedDateKey = @"createdDate";
static NSString* const UserKey = @"user";
static NSString* const VideoStreamKey = @"videostream";



@interface Comment()

@end

@implementation Comment

- (id)initWithRecord: (CKRecord*) record WithUserRecord: (CKRecord*) userRecord{
    self = [super init];
    if(self){
        self.record = record;
        self.userRecord = userRecord;
    }
    return self;
}

-(NSString*) createdDate{
    NSDate* date = self.record[CreatedDateKey];
    NSString* agoString = [PrettyDateFormatter agoFormatterFromDate:date];
    return agoString;
}
-(NSString*) text{
    return self.record[TextKey];
}

-(NSString*)fullname{
    return self.userRecord[FullNameKey];
}

-(NSURL*)avatorURL{
    return ((CKAsset*)self.userRecord[AvatorKey]).fileURL;
}

-(CKReference *)reference{
    return [[CKReference alloc]initWithRecord:self.record action:CKReferenceActionNone];
}

+(void)sendComment: (NSString*)text inVideo: (VideoStream*)videostream completionHandler: (void (^)(Comment* comment, NSError* error)) callBack{
    //get the current loggedin credential
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CKRecord* loggedInUserRecord = delegate.loggedInRecord;
    CKReference* userReference = [[CKReference alloc]initWithRecord:loggedInUserRecord action:CKReferenceActionDeleteSelf];
  
    //create a comment record to insert to database
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    NSDate* now = [[NSDate alloc]init];
    CKRecord* record = [[CKRecord alloc]initWithRecordType:@"Comment"];
    record[TextKey] = text;
    record[UserKey] = userReference;
    record[VideoStreamKey] = videostream.reference;
    record[CreatedDateKey] = now;
    [db saveRecord:record completionHandler:^(CKRecord * _Nullable commentRecord, NSError * _Nullable error) {
        if(error == nil){
            //add comment reference to the videostream
            CKReference* commentReference = [[CKReference alloc]initWithRecord:commentRecord action:CKReferenceActionNone];
            [videostream addCommentReference:commentReference completionHandler:nil];
            Comment* comment = [[Comment alloc]initWithRecord:commentRecord WithUserRecord:loggedInUserRecord];
            callBack(comment, error);
        }else{
            NSLog(@"error is %@", error.localizedDescription);
            NSLog(@"Retry Again Now...");
            [Comment sendComment:text inVideo:videostream completionHandler:callBack];
        }
    }];
}

+(void) fetchCommentForVideoStreamReference: (CKReference*) videoStreamReference completionHandler: (void (^)(NSArray<Comment*>* comments, NSError* error))callback {
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"videostream == %@", videoStreamReference];
    CKQuery* query = [[CKQuery alloc]initWithRecordType:@"Comment" predicate:predicate];
    NSSortDescriptor* descriptor = [[NSSortDescriptor alloc]initWithKey:CreatedDateKey ascending:NO];
    query.sortDescriptors = @[descriptor];
    [db performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable commentRecords, NSError * _Nullable error) {
        __block NSInteger recordFetchedCompleted = 0;
        __block NSMutableArray<Comment*>* commentsResult = [[NSMutableArray alloc]init];
        if(error == nil){
            for(CKRecord* commentRecord in commentRecords){
                CKReference* userReference = commentRecord[UserKey];
                __block Comment* comment = [[Comment alloc]initWithRecord:commentRecord WithUserRecord:nil];
                [commentsResult addObject:comment];
                [User fetchUserWithReference:userReference completionHandler:^(CKRecord *userRecord, NSError *error) {
                    recordFetchedCompleted += 1;
                    comment.userRecord = userRecord;
                    if(recordFetchedCompleted == commentRecords.count){
                        callback(commentsResult, error);
                    }
                }];
            }
        }
    }];
}


+(void)fetchUserRecordByCommentRecord:(CKRecord*)commentRecord completionHandler: (void (^)(CKRecord *userRecord, NSError *error)) callback{
    CKReference* userReference = commentRecord[UserKey];
    [User fetchUserWithReference:userReference completionHandler:^(CKRecord *userRecord, NSError *error) {
        callback(userRecord, error);
    }];
}


+(void)deleteCommentInVideoStream:(Comment*) comment inVideoStream:(VideoStream*) videoStream completionHandler: (void (^)(CKRecordID *recordID, NSError *error)) callback{
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    [db deleteRecordWithID:comment.record.recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        if(error == nil){
            [videoStream deleteComment:comment.reference completionHandler:^(CKRecord *videoRecord, NSError *error) {
                if(error == nil){
                    callback(recordID, nil);
                }else{
                    callback(nil, error);
                }
            }];
        }else{
            //try again
            NSLog(@"error %@", error.localizedDescription);
            [Comment deleteCommentInVideoStream:comment inVideoStream:videoStream completionHandler:callback];
        }
    }];
}

@end
