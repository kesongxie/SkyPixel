//
//  ChooseDeviceTableViewController.h
//  SkyPixel
//
//  Created by Xie kesong on 12/28/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <UIKit/UIkit.h>
#import "ShotDevice.h"

static NSString* const SelectedShotDevicesNotificationUserInfoKey = @"SelectedShotDevices";
static NSString* const FinishedPickingShotDeviceNotificationName = @"FinishedPickingShotDevice";

@interface ChooseDeviceViewController : UIViewController

@property (strong, nonatomic) ShotDevice* preSelectedShotDevice;
@end
