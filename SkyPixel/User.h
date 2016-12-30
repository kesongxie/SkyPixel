//
//  User.h
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import <UIKit/UIKit.h>


static NSString* const FullNameKey = @"fullname";
static NSString* const BioKey = @"bio";
static NSString* const EmailKey = @"email";
static NSString* const AvatorKey = @"avator";
static NSString* const CoverKey = @"cover";

@interface User : NSObject

@property (strong, nonatomic) CKRecord* record;
@property (strong, nonatomic) NSMutableArray<CKRecord*>* videoStreamRecord;
//compute from the record class
@property (strong, readonly, nonatomic) CKReference* reference;
@property (strong, readonly, nonatomic) NSString* fullname;
@property (strong, readonly, nonatomic) NSString* bio;
@property (strong, readonly, nonatomic) NSString* email;
@property (strong, readonly, nonatomic) NSURL* avatorUrl;
@property (strong, readonly, nonatomic) NSURL* coverUrl;
@property (strong, readonly, nonatomic) UIImage * thumbImage;
@property (strong, readonly, nonatomic) UIImage * coverThumbImage;


-(id)initWithRecord: (CKRecord*) record;

+(void) fetchUserWithReference:(CKReference*) reference completionHandler: (void (^)(CKRecord* userRecord, NSError* error)) callback;

+(void)loggedIn: (void(^)(User* user, NSError* error)) callback;

@end
