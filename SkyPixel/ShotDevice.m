//
//  ShotDevice.m
//  SkyPixel
//
//  Created by Xie kesong on 12/28/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "ShotDevice.h"

static NSString *const ShotDeviceRecordType = @"ShotDevice";
@interface ShotDevice()
@end

@implementation ShotDevice

- (id)initWithRecord: (CKRecord*) record{
    self = [super init];
    if(self){
        self.record = record;
    }
    return self;
}

-(NSString *)deviceName{
    return self.record[DeviceNameKey];
}

-(NSURL*)thumbnailURL{
    return ((CKAsset*)self.record[ThumbnailKey]).fileURL;
}

-(CKReference *)reference{
    return [[CKReference alloc]initWithRecord:self.record action:CKReferenceActionNone];
}

-(UIImage *)thumbnailImage{
    NSURL *thumbnailURL = self.thumbnailURL;
    NSData *imageData = [[NSData alloc]initWithContentsOfURL:thumbnailURL];
    return [[UIImage alloc]initWithData:imageData];
}


-(BOOL)isEqual:(id)object{
    if([object isKindOfClass:[ShotDevice class]]){
        return [self.deviceName isEqualToString:((ShotDevice*)object).deviceName];
    }
    return NO;
}

+(void)fetchAvailabeDevices: (void(^)(NSArray<ShotDevice *>  *results, NSError  *error))callback{
    CKDatabase *db = [CKContainer defaultContainer].publicCloudDatabase;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    CKQuery *query = [[CKQuery alloc]initWithRecordType:ShotDeviceRecordType predicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:DeviceNameKey ascending:YES];
    query.sortDescriptors = @[sortDescriptor];
    [db performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *>  *results, NSError  *error) {
        if(error == nil){
            NSMutableArray<ShotDevice *> *resultArray = [[NSMutableArray alloc]init];
            for(CKRecord *record in results){
                ShotDevice *shotDevice = [[ShotDevice alloc]initWithRecord:record];
                [resultArray insertObject:shotDevice atIndex:0];
            }
            
            NSArray *returnArray = [NSArray arrayWithArray:resultArray];
            callback(returnArray, error);
        }else{
            NSLog(@"error: %@", error.localizedDescription);
        }
    }];
}

@end
