//
//  SkyCastViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/4/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "SkyCastViewController.h"

@interface SkyCastViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation SkyCastViewController


- (void) viewDidLoad{
    [super viewDidLoad];
    [self updateUI];
    self.mapView.delegate = self;
}



//MARK: - UPATE UI
- (void) updateUI{
    [self.navigationController.navigationBar setBarTintColor: [UIColor blackColor]];
    UIFont* titleFont = [UIFont fontWithName:@"Avenir-Heavy" size:17.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: titleFont,    NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
