//
//  VideoAsset.h
//  SkyPixel
//
//  Created by Xie kesong on 12/22/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import <Foundation/Foundation.h>

static NSString* const VideoAssetRecordType = @"VideoAsset";
static NSString* const VideoStreamKey = @"videostream";
static NSString* const AssetKey = @"asset";

@interface VideoAsset : NSObject

+(void)loadAssetForVideoStreamReference: (CKReference*) videoStreamReference completionHandler: (void(^)(NSArray<CKRecord *>* results, NSError* error)) callback;

+(void)saveVideoWithVideoStreamReference: (CKAsset*)videoAsset withReference: (CKReference*)reference completionHandler: (void(^)(CKRecord* record, NSError* error)) callback;

@end
