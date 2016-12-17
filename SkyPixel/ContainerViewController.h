//
//  ContainerViewController.h
//  SkyPixel
//
//  Created by Xie kesong on 12/15/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ContainerViewController : UIViewController

-(void) toggleLeftMainView;

//this brings search explore view to the fornt
-(void) bringExploreViewToFront;

//this brings search main view to the fornt
-(void) bringMainViewToFront;

@end
