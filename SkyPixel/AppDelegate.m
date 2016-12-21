//
//  AppDelegate.m
//  SkyPixel
//
//  Created by Xie kesong on 12/1/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "AppDelegate.h"

NSNotificationName const DocumentReadyNotificationName = @"DocumentReadyNotification";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //fetch a user and log in
    CKDatabase* db = [[CKContainer defaultContainer] publicCloudDatabase];
    NSString* email = @"john@skypixel.com";
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"email=%@", email];
    CKQuery* fetchQuery = [[CKQuery alloc]initWithRecordType:@"User" predicate:predicate];
    
    [db performQuery:fetchQuery inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable users, NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"%@", error.localizedDescription);
        }else{
            if(users.count == 1){
                self.loggedInRecord = users.firstObject;
                NSLog(@"The logged in user is %@", self.loggedInRecord[@"fullname"]);
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


@end
