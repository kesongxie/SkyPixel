//
//  ContainerViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/15/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "CoreConstant.h"
#import "ContainerViewController.h"

static NSString *const EmbedSegueLeftPanelIden = @"EmbedSegueLeftPanelIden";
static NSString *const EmbedSegueSearchIden = @"EmbedSegueSearchIden";
static NSString *const EmbedSegueSkyCastIden = @"EmbedSegueSkyCastIden";

@interface ContainerViewController()

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *exploreSearchView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewTrailingConstraint;
@property (strong, nonatomic) UIView *overlayView;
@property (nonatomic) BOOL isStatusBarHidden;
@property (nonatomic) BOOL isLeftPaneOpened;
@property (nonatomic) BOOL isStatusBarStyleSet;
@property (nonatomic) UIStatusBarStyle statusBarStyle;

@end

@implementation ContainerViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mainViewShouldDisappear:) name:MainViewShouldDisappearNotificationName object:nil];
    self.overlayView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.overlayView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetMainViewToCenter)];
    [self.mainView addGestureRecognizer:tap];
}


-(void) viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}


-(UIStatusBarStyle) preferredStatusBarStyle{
    return (self.isStatusBarStyleSet) ? self.statusBarStyle: UIStatusBarStyleLightContent;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationSlide;
}

-(void) mainViewShouldDisappear: (NSNotification*)notification{
    CGFloat adjustConstraint = [UIScreen mainScreen].bounds.size.width;
    [self.view layoutIfNeeded];
    self.mainViewLeadingConstraint.constant =  adjustConstraint;
    self.mainViewTrailingConstraint.constant = -adjustConstraint;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(BOOL) prefersStatusBarHidden{
    return self.isStatusBarHidden;
}

-(void) resetMainViewToCenter{
    if(self.isLeftPaneOpened){
        [self toggleLeftMainView];
    }
}

/**
 Show search explore view
 */
-(void) bringExploreViewToFront{
    self.isStatusBarStyleSet = YES;
    self.statusBarStyle = UIStatusBarStyleDefault;
    [self.view bringSubviewToFront:self.exploreSearchView];
    [self setNeedsStatusBarAppearanceUpdate];
}

/**
 Show main view
 */
-(void) bringMainViewToFront{
    self.isStatusBarStyleSet = YES;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    [self.view bringSubviewToFront:self.mainView];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void) bringSearchViewToBack{
    [self.view sendSubviewToBack:self.exploreSearchView];
}

/**
 Toggle left profile panel
 */
-(void) toggleLeftMainView{
    CGFloat adjustConstraint = 0;
    CGFloat overlayEndAlpha = 0;
    if(!self.isLeftPaneOpened){
        //open it
        adjustConstraint = 0.85  *self.view.frame.size.width;
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


//MARK: - Prepare for segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:EmbedSegueSearchIden]){
        self.locationSearchNavigationController = segue.destinationViewController;
    }else if([segue.identifier isEqualToString:EmbedSegueSkyCastIden]){
        self.skyCastNavigationViewController = segue.destinationViewController;
    }else if([segue.identifier isEqualToString:EmbedSegueLeftPanelIden]){
        self.profileLeftPanelViewController = segue.destinationViewController;
    }
}


@end
