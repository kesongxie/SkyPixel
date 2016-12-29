//
//  ProfileLeftPanelViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/15/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "ProfileLeftPanelViewController.h"
#import "AppDelegate.h"
#import "UIImageView+ProfileAvator.h"
#import "ContainerViewController.h"
#import "PostNavigationController.h"
#import "ProfileCollectionViewController.h"
#import "HorizontalSlideInAnimator.h"
#import "User.h"

@interface ProfileLeftPanelViewController() 

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverHeightConstriant;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *postBtn;
@property (strong, nonatomic) ContainerViewController* parentContainerViewController;
@property (strong, nonatomic) HorizontalSlideInAnimator* animator;
@property (nonatomic) CGFloat orginCoverHeight;


@end

@implementation ProfileLeftPanelViewController

- (IBAction)postBtnTapped:(UIButton *)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PostNavigationController* postNVC = (PostNavigationController*)[storyboard instantiateViewControllerWithIdentifier:PostNavigationControllerIden];
    if(postNVC){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentContainerViewController toggleLeftMainView];
            [self presentViewController:postNVC animated:YES completion:nil];
        });
    }
}


-(void)viewDidLoad{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceVertical = YES;
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    User* loggedInUser = [[User alloc]initWithRecord:delegate.loggedInRecord];
    [self.avatorImageView becomeAvatorProifle:loggedInUser.thumbImage];
    self.avatorImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatorImageView.layer.borderWidth = 3.0;
    self.fullnameLabel.text = loggedInUser.fullname;
    self.coverImageView.image = loggedInUser.coverThumbImage;
    self.bioLabel.text = loggedInUser.bio;
    self.postBtn.layer.cornerRadius = 3.0;
    
    //add tap gesture for avator image view
    UITapGestureRecognizer* avatorTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatorImageViewTapped:)];
    [self.avatorImageView addGestureRecognizer:avatorTapGesture];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGRect leftViewRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.85, self.view.frame.size.height);
    self.view.frame = leftViewRect;
    [self adjustCoverView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([self.parentViewController isKindOfClass:[ContainerViewController class]]){
        self.parentContainerViewController = (ContainerViewController*)self.parentViewController;
    }
}

-(void)adjustCoverView{
    CGSize coverImageSize = self.coverImageView.image.size;
    self.coverHeightConstriant.constant = self.view.frame.size.width * coverImageSize.height /  coverImageSize.width;
    self.orginCoverHeight = self.coverHeightConstriant.constant;
}

-(void)avatorImageViewTapped: (UITapGestureRecognizer*)gesture{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileCollectionViewController* profileCVC = (ProfileCollectionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ProfileCollectionViewController"];
    if(profileCVC){
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        profileCVC.user = appDelegate.loggedInUser;
        [self.parentContainerViewController toggleLeftMainView];
        profileCVC.transitioningDelegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:profileCVC animated:YES completion:nil];
        });
    }
}

//MARK: UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y < 0){
        CGRect coverRect = CGRectMake(0, scrollView.contentOffset.y,self.coverImageView.frame.size.width, self.orginCoverHeight + (-scrollView.contentOffset.y));
        self.coverImageView.frame = coverRect;
    }
}

//custom transition
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.animator = [[HorizontalSlideInAnimator alloc] init];
    return self.animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self.animator;
}

@end
