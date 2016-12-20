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

@interface VideoStream : NSObject


@property (strong, nonatomic) CKRecord* record;
@property (strong, nonatomic) User* user;

//compute from record property
@property (strong, readonly, nonatomic) NSString* title;
@property (strong, readonly, nonatomic) NSString* description;
@property (strong, readonly, nonatomic) CLLocation* location;
@property (strong, readonly, nonatomic) NSURL* url;
@property (strong, readonly, nonatomic) NSArray<CKReference*>* favorUserList;
@property (readonly, nonatomic) NSInteger live;

- (id)initWithCKRecord: (CKRecord*)record;

//initialize the user property from the record itself
-(void)fetchUserForVideoStream: (void (^)(CKRecord* userRecord, NSError* error)) callBack;

-(BOOL) isLive;

-(void)deleteFavorUser: (CKReference*)userReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack;

-(void)addFavorUser: (CKReference*)userReference completionHandler: (void (^)(CKRecord* videoRecord, NSError* error)) callBack;


@end
