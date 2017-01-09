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
static NSString *const FinishedLoggedInNotificationInfoUserKey = @"user";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/*! @brief The CKRecord for the user who is currently loggedIn */
@property (strong, nonatomic) CKRecord *loggedInRecord;

/*! @brief The User who is currently loggedIn */
@property (strong, nonatomic) User *loggedInUser;

@end

