//
//  ShotDevice.h
//  SkyPixel
//
//  Created by Xie kesong on 12/28/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import <UIKit/UIKit.h>


static NSString* const DeviceNameKey = @"deviceName";
static NSString* const ThumbnailKey = @"thumbnail";

@interface ShotDevice : NSObject

@property (strong, nonatomic) CKRecord* record;
//compute from the record
@property (strong, readonly, nonatomic) CKReference* reference;
@property (strong, readonly, nonatomic) NSString* deviceName;
@property (strong, readonly, nonatomic) NSURL* thumbnailURL;
@property (strong, readonly, nonatomic) UIImage* thumbnailImage;

-(BOOL)isEqual:(id)object;

+(void)fetchAvailabeDevices: (void(^)(NSArray<ShotDevice *> * results, NSError * error))callback;

@end
