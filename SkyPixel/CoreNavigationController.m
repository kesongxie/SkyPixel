//
//  CoreNavigationController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/26/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "CoreNavigationController.h"


static NSString *const NavigationBarTitleFontName = @"Avenir-Heavy";
static CGFloat const NavigationBarTitleFontSize = 17;

@interface CoreNavigationController ()

@end

@implementation CoreNavigationController

- (void) viewDidLoad{
    [super viewDidLoad];
    [self.navigationBar setBarTintColor: [UIColor blackColor]];
    UIFont *titleFont = [UIFont fontWithName: NavigationBarTitleFontName size: NavigationBarTitleFontSize];
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName: titleFont,    NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
