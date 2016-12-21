//
//  VideoStream.h
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CloudKit/CloudKit.h>
#import "CKReference+Comparison.h"
#import "User.h"


//keys for columns in the CloudKit database
static NSString* const TitleKey = @"title";
static NSString* const LocationKey = @"location";
static NSString* const VideoKey = @"video";
static NSString* const LiveKey = @"live";
static NSString* const DescriptionKey = @"description";
static NSString* const FavorUserListKey = @"favorUserList";
static NSString* const CommentListKey = @"commentList";

@interface VideoStream : NSObject


@property (strong, nonatomic) CKRecord* record;
@property (strong, nonatomic) User* user;

//compute from record property
@property (strong, readonly, nonatomic) NSString* title;
@property (strong, readonly, nonatomic) NSString* description;
@property (strong, readonly, nonatomic) CLLocation* location;
@property (strong, readonly, nonatomic) NSURL* url;
@property (strong, readonly, nonatomic) CKReference* reference;
@property (strong, nonatomic) NSMutableArray<CKReference*>* favorUserList;
@property (strong, nonatomic) NSMutableArray<CKReference*>* commentReferenceList;

@property (readonly, nonatomic) NSInteger live;

- (id)initWithCKRecord: (CKRecord*)record;

//initialize the user property from the record itself
-(void)fetchUserForVideoStream: (void (^)(CKRecord* userRecord, NSError* error)) callBack;

-(BOOL) isLive;

-(void)deleteFavorUser: (CKReference*)userReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack;

-(void)addFavorUser: (CKReference*)userReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack;

-(void)addCommentReference: (CKReference*)commentReference completionHandler: (void(^)(NSArray<CKRecord*>* records, NSArray<CKRecordID*>* recordIDs, NSError* error)) callback;
@end
