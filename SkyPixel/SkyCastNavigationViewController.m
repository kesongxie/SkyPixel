//
//  SkyCastNavigationViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/4/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "SkyCastNavigationViewController.h"
#import "CoreConstant.h"
#import "ShotDetailViewController.h"


@interface SkyCastNavigationViewController ()

@end

@implementation SkyCastNavigationViewController


- (void) viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushShotDetailAfterFinishingSharing:) name:FinishedSharingPostNotificationName object:nil];
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)pushShotDetailAfterFinishingSharing: (NSNotification*)notification{
    VideoStream* videoStream = notification.userInfo[FinishedSharingPostVideoStreamInfoKey];
    if(videoStream){
        [ShotDetailViewController pushShotDetailWithVideoStream:self withVideoStream:videoStream];
    }
}

@end


