//
//  AppDelegate.h
//  SkyPixel
//
//  Created by Xie kesong on 12/1/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "User.h"

static NSNotificationName const FinishedLoggedInNotificationName = @"FinishedLoggedInNotificationName";
static NSString* const UserRecordKey = @"UserRecord";


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CKRecord* loggedInRecord;
@property (strong, nonatomic) User* loggedInUser;

@end

