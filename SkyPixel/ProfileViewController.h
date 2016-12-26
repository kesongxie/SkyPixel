//
//  ProfileViewController.h
//  SkyPixel
//
//  Created by Xie kesong on 12/25/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileViewController : UIViewController<UIViewControllerTransitioningDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) User* user;

@end
