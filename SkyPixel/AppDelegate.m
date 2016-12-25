//
//  AppDelegate.m
//  SkyPixel
//
//  Created by Xie kesong on 12/1/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

//create a video stream record
- (CKRecord*) getVideoStreamRecord: (NSString*)title withDescription: (NSString*)description  fromLocation: (CLLocation*)location isLive: (NSInteger)live whoShot: (CKReference*)user clipAsset: (CKAsset*) asset;

//create a asset from file info
- (CKAsset*) getCKAssetFromFileName: (NSString*)filename withExtension:(NSString*)ext inDirectory: (NSString*)dir;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //fetch a user and log in
    CKDatabase* db = [[CKContainer defaultContainer] publicCloudDatabase];
 //   NSString* email = @"john@skypixel.com";
    NSString* email = @"kesongxie@skypixel.com";
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"email=%@", email];
    CKQuery* fetchQuery = [[CKQuery alloc]initWithRecordType:@"User" predicate:predicate];
    [db performQuery:fetchQuery inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable users, NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"%@", error.localizedDescription);
        }else{
            if(users.count == 1){
                self.loggedInRecord = users.firstObject;
                NSLog(@"The logged in user is %@", self.loggedInRecord[@"fullname"]);
                NSDictionary* userInfo = @{UserRecordKey: self.loggedInRecord};
                NSNotification* notification = [[NSNotification alloc]initWithName:FinishedLoggedInNotificationName object:self userInfo:userInfo];
                [[NSNotificationCenter defaultCenter]postNotification:notification];
            }
        }
    }];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



-(void)createRecordForUser: (CKRecord*)user{
    if(user){
        //create a videostream record
        //paris
        CKRecord* videoStreamRecord1 = [self getVideoStreamRecord: @"Eiffel Tower Paris" withDescription: @"Shot by Mavic" fromLocation:[[CLLocation alloc] initWithLatitude:48.857610 longitude: 2.294083] isLive:1 whoShot:[[CKReference alloc] initWithRecord:user action:CKReferenceActionDeleteSelf] clipAsset:[self getCKAssetFromFileName:@"clip1" withExtension:@"mp4" inDirectory:@"clip"]];
        CKRecord* videoStreamRecord2 = [self getVideoStreamRecord: @"Paris Skyline View Of The City and Eiffel Tower From The Arc De Triomphe" withDescription: @"Shot by Phantom 4" fromLocation:[[CLLocation alloc] initWithLatitude:48.857697 longitude: 2.297494] isLive:0 whoShot:[[CKReference alloc] initWithRecord:user action:CKReferenceActionDeleteSelf] clipAsset:[self getCKAssetFromFileName:@"clip2" withExtension:@"mp4" inDirectory:@"clip"]];
        
        //shenzhen
        CKRecord* videoStreamRecord3 = [self getVideoStreamRecord: @"DJI - Phantom 4 China Launch" withDescription: @"" fromLocation:[[CLLocation alloc] initWithLatitude:22.543096 longitude: 114.057865] isLive:1 whoShot:[[CKReference alloc] initWithRecord:user action:CKReferenceActionDeleteSelf] clipAsset:[self getCKAssetFromFileName:@"clip3" withExtension:@"mp4" inDirectory:@"clip"]];
        
        //ucsd
        CKRecord* videoStreamRecord4 = [self getVideoStreamRecord: @"UCSD, Torrey Pines, Sunset Cliffs From Above"  withDescription: @"" fromLocation:[[CLLocation alloc] initWithLatitude:32.880334 longitude: -117.245793] isLive:1 whoShot:[[CKReference alloc] initWithRecord:user action:CKReferenceActionDeleteSelf] clipAsset:[self getCKAssetFromFileName:@"clip4" withExtension:@"mp4" inDirectory:@"clip"]];
        
        
        CKRecord* videoStreamRecord5 = [self getVideoStreamRecord: @"Geisel Library Drone - UCSD - University of California San Diego" withDescription: @"Geisel Library from above" fromLocation:[[CLLocation alloc] initWithLatitude:32.881019 longitude: -117.237827] isLive:0 whoShot:[[CKReference alloc] initWithRecord:user action:CKReferenceActionDeleteSelf] clipAsset:[self getCKAssetFromFileName:@"clip5" withExtension:@"mp4" inDirectory:@"clip"]];
        
        
        CKRecord* videoStreamRecord6 = [self getVideoStreamRecord: @"Winter at Stanford University recording with drone" withDescription: @"Winter at stanford is purely beautiful" fromLocation:[[CLLocation alloc] initWithLatitude:37.427517 longitude: -122.170233] isLive:1 whoShot:[[CKReference alloc] initWithRecord:user action:CKReferenceActionDeleteSelf] clipAsset:[self getCKAssetFromFileName:@"clip6" withExtension:@"mp4" inDirectory:@"clip"]];
        
        NSArray<CKRecord*>* recordToBeSaved = @[videoStreamRecord1, videoStreamRecord2, videoStreamRecord3, videoStreamRecord4, videoStreamRecord5, videoStreamRecord6];
        
        //configure the CKModifyRecordsOperation and save multiple records
        CKDatabase* publicDB = [[CKContainer defaultContainer] publicCloudDatabase];
        CKModifyRecordsOperation* saveOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:recordToBeSaved recordIDsToDelete:nil];
        saveOperation.database = publicDB;
        saveOperation.atomic = NO;
        saveOperation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> *savedRecords, NSArray<CKRecordID *> *deletedRecordIDs, NSError *operationError){
            NSLog(@"%@", savedRecords);
        };
        NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
        
        //save records
        [operationQueue addOperation:saveOperation];
    }
}

- (CKRecord*) getVideoStreamRecord: (NSString*)title withDescription: (NSString*)description  fromLocation: (CLLocation*)location isLive: (NSInteger)live whoShot: (CKReference*)user clipAsset: (CKAsset*) asset  {
    CKRecord* videoStreamRecord = [[CKRecord alloc] initWithRecordType:@"videostream"];
    videoStreamRecord[@"title"] = title;
    videoStreamRecord[@"location"] = location;
    videoStreamRecord[@"description"] = description;
    videoStreamRecord[@"live"] = [[NSNumber alloc] initWithInt:live];
    videoStreamRecord[@"user"] = user;
    videoStreamRecord[@"width"] = [NSNumber numberWithInt:1280];
    videoStreamRecord[@"height"] = [NSNumber numberWithInt:720];
    
    return videoStreamRecord;
}


- (CKAsset*) getCKAssetFromFileName: (NSString*)filename withExtension:(NSString*)ext inDirectory: (NSString*)dir{
    NSString* pathname = [[NSBundle mainBundle] pathForResource:filename ofType: ext inDirectory:dir];
    if(pathname){
        NSURL* url = [[NSURL alloc] initFileURLWithPath:pathname];
        if(url){
            CKAsset* asset = [[CKAsset alloc] initWithFileURL:url];
            return asset;
        }
    }
    return nil;
}

@end
