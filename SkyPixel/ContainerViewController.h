//
//  ContainerViewController.h
//  SkyPixel
//
//  Created by Xie kesong on 12/15/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SkyCastNavigationViewController.h"
#import "LocationSearchNavigationController.h"
#import "ProfileLeftPanelViewController.h"

@interface ContainerViewController : UIViewController

@property (strong, nonatomic) LocationSearchNavigationController* locationSearchNavigationController;
@property (strong, nonatomic) SkyCastNavigationViewController* skyCastNavigationViewController;
@property (strong, nonatomic) ProfileLeftPanelViewController* profileLeftPanelViewController;

-(void) toggleLeftMainView;

//this brings search explore view to the fornt
-(void) bringExploreViewToFront;

//this brings search main view to the fornt
-(void) bringMainViewToFront;

//this brings search view to the back
-(void) bringSearchViewToBack;

@end
