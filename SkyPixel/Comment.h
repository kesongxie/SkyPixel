//
//  Comment.h
//  SkyPixel
//
//  Created by Xie kesong on 12/19/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "VideoStream.h"
#import "User.h"

@interface Comment : NSObject

@property (strong, nonatomic) CKRecord *record;
@property (strong, nonatomic) CKRecord *userRecord;
//compute from the record class
@property (strong, readonly, nonatomic) CKReference *reference;
@property (strong, readonly, nonatomic) NSString *createdDate;
@property (strong, readonly, nonatomic) NSString *text;
@property (strong, readonly, nonatomic) NSString *fullname;
@property (strong, readonly, nonatomic) NSURL *avatorURL;


-(id)initWithRecord: (CKRecord*) record WithUserRecord: (CKRecord*) userRecord;

/**
 Add a comment to a video stream
*/
+(void)sendComment: (NSString*)text inVideo: (VideoStream*)videostream completionHandler: (void (^)(Comment *comment, NSError *error)) callBack;


/**
 Delete a given comment in the video stream
 */
+(void)deleteCommentInVideoStream:(Comment*) comment inVideoStream:(VideoStream*) videoStream completionHandler: (void (^)(CKRecordID *recordID, NSError *error)) callback;

/**
 Fetch all the comments given a reference to a video stream
 */
+(void) fetchCommentForVideoStreamReference: (CKReference*) videoStreamReference completionHandler: (void (^)(NSArray<Comment*> *comments, NSError *error))callback;


/**
 Fetch the user record associate with the comment record
 */
+(void)fetchUserRecordByCommentRecord:(CKRecord*)commentRecord completionHandler: (void (^)(CKRecord *userRecord, NSError *error)) callback;

@end

