//
//  ContainerViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/15/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "ContainerViewController.h"
#import "SkyCastNavigationViewController.h"

@interface ContainerViewController()

//@property (strong, nonatomic) IBOutlet UIView *rootView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewTrailingConstraint;
@property (nonatomic) BOOL isStatusBarHidden;
@property (nonatomic) BOOL isLeftPaneOpened;
@property (strong, nonatomic) UIView* overlayView;

@end

@implementation ContainerViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mainViewShouldDisappear:) name:@"mainViewShouldDisappear" object:nil];
    
    self.overlayView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.overlayView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetMainViewToCenter)];
    [self.view addGestureRecognizer:tap];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}


-(void)mainViewShouldDisappear: (NSNotification*)notification{
    CGFloat adjustConstraint = [UIScreen mainScreen].bounds.size.width;
    [self.view layoutIfNeeded];
    self.mainViewLeadingConstraint.constant =  adjustConstraint;
    self.mainViewTrailingConstraint.constant = -adjustConstraint;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void) viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}

-(void) resetMainViewToCenter{
    if(self.isLeftPaneOpened){
        [self toggleLeftMainView];
    }
}

-(void) toggleLeftMainView{
    CGFloat adjustConstraint = 0;
    CGFloat overlayEndAlpha = 0;
    if(!self.isLeftPaneOpened){
        //open it
        adjustConstraint = 0.85 * self.view.frame.size.width;
        [self.mainView addSubview:self.overlayView];
        overlayEndAlpha = 0.7;
    }
    [self.view layoutIfNeeded];
    self.mainViewLeadingConstraint.constant =  adjustConstraint;
    self.mainViewTrailingConstraint.constant = -adjustConstraint;
    self.isStatusBarHidden = !self.isStatusBarHidden;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        [self setNeedsStatusBarAppearanceUpdate];
        self.overlayView.alpha = overlayEndAlpha;
    } completion:^(BOOL finished){
        if(finished){
            if(self.isLeftPaneOpened){
                [self.overlayView removeFromSuperview];
            }
            self.isLeftPaneOpened = !self.isLeftPaneOpened;
            
        }
    }];
}

- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationSlide;
}

-(BOOL) prefersStatusBarHidden{
    return self.isStatusBarHidden;
}


@end
