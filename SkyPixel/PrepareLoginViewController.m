//
//  PrepareLoginViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/24/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrepareLoginViewController.h"
#import "ContainerViewController.h"

static NSString* const SegueIden = @"PresentMainContainerViewController";
static NSString* const MainStoryBoardName = @"Main";
static NSString* const ContainerViewIden = @"ContainerViewController";

@interface PrepareLoginViewController()

@end

@implementation PrepareLoginViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userloggedIn:) name:FinishedLoggedInNotificationName object:nil];
}

-(void)userloggedIn: (NSNotification*)notification{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:MainStoryBoardName bundle:nil];
    ContainerViewController* mainContainerVC = [storyboard instantiateViewControllerWithIdentifier:ContainerViewIden];
    if(mainContainerVC){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:mainContainerVC animated:YES];
        });
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


@end
