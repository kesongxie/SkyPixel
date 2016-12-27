//
//  VideoStream.h
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "CKReference+Comparison.h"
#import "User.h"


//keys for columns in the CloudKit database
static NSString* const VideoStreamRecordType = @"VideoStream";
static NSString* const TitleKey = @"title";
static NSString* const LocationKey = @"location";
static NSString* const LiveKey = @"live";
static NSString* const UserReferenceKey = @"user";
static NSString* const DescriptionKey = @"description";
static NSString* const FavorUserListKey = @"favorUserList";
static NSString* const CommentListKey = @"commentList";
static NSString* const ThumbnailListKey = @"thumbnail";
static NSString* const ViewKey = @"view";
static NSString* const WidthKey = @"width";
static NSString* const HeightKey = @"height";

@interface VideoStream : NSObject


@property (strong, nonatomic) CKRecord* record;
@property (strong, nonatomic) User* user;

//compute from record property
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (strong, readonly, nonatomic) NSString* title;
@property (strong, readonly, nonatomic) NSString* description;
@property (strong, readonly, nonatomic) CLLocation* location;
@property (strong, readonly, nonatomic) CKReference* reference;
@property (strong, readonly, nonatomic) CKReference* userReference;
@property (strong, readonly, nonatomic) NSURL* thumbnail;
@property (strong, readonly, nonatomic) UIImage* thumbImage;
@property (strong, nonatomic) NSNumber* view;
@property (strong, nonatomic) NSMutableArray<CKReference*>* favorUserList;
@property (strong, nonatomic) NSMutableArray<CKReference*>* commentReferenceList;
@property (readonly, nonatomic) NSInteger live;


- (id)initWithCKRecord: (CKRecord*)record;

//initialize the user property from the record itself
-(void)fetchUserForVideoStream: (void (^)(CKRecord* userRecord, NSError* error)) callBack;

-(BOOL) isLive;

-(void)loadVideoAsset: (void(^)(CKAsset* videoAsset, NSError *error)) callback;

-(void)deleteFavorUser: (CKReference*)userReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack;

-(void)addFavorUser: (CKReference*)userReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack;

-(void)addCommentReference: (CKReference*)commentReference completionHandler: (void(^)(NSArray<CKRecord*>* records, NSArray<CKRecordID*>* recordIDs, NSError* error)) callback;

-(void)deleteComment: (CKReference*)commentReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack;

+(void)fetchVideoStreamForUser:(CKReference*)userReference completionHandler:(void(^)(NSArray<CKRecord*>* results, NSError* error)) callback;

+(void)fetchLive: (CLLocation*)location withRadius: (CGFloat)searchRadius completionHandler:(void(^)(NSMutableArray<VideoStream*>* videoStreams, NSError* error)) callback;

@end
