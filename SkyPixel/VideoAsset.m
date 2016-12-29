//
//  VideoAsset.m
//  SkyPixel
//
//  Created by Xie kesong on 12/22/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "VideoAsset.h"


@interface VideoAsset()


@end

@implementation VideoAsset

+(void)loadAssetForVideoStreamReference: (CKReference*) videoStreamReference completionHandler: (void(^)(NSArray<CKRecord *>* results, NSError* error)) callback{
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", VideoStreamKey, videoStreamReference];
    CKQuery* query = [[CKQuery alloc]initWithRecordType:VideoAssetRecordType predicate:predicate];
    [db performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *>* results, NSError* error) {
        if(error == nil){
            callback(results, nil);
        }else{
            NSLog(@"Error %@", error.localizedDescription);
        }
    }];
}


+(void)saveVideoWithVideoStreamReference: (CKAsset*)videoAsset withReference: (CKReference*)reference completionHandler: (void(^)(CKRecord* record, NSError* error)) callback{
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    CKRecord* record = [[CKRecord alloc]initWithRecordType:VideoAssetRecordType];
    record[AssetKey] = videoAsset;
    record[VideoStreamKey] = reference;
    [db saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if(error == nil){
             callback(record, nil);
        }else{
            NSLog(@"failed to save video asset, Error:%@", error.localizedDescription);
            callback(nil, error);
        }
    }];
}

@end
