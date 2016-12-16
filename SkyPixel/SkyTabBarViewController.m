//
//  SkyTabBarViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/4/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "SkyTabBarViewController.h"

@interface SkyTabBarViewController ()

@end

@implementation SkyTabBarViewController

-(void)viewDidLoad{
    UIColor* whiteColor = [UIColor whiteColor];
    [self.tabBar setBarTintColor:whiteColor];
    self.tabBar.translucent = NO;
}

@end
