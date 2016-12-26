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
#import "User.h"

@interface ProfileLeftPanelViewController() 

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverHeightConstriant;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *postBtn;
@property (nonatomic) CGFloat orginCoverHeight;

@end

@implementation ProfileLeftPanelViewController

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
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGRect leftViewRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.85, self.view.frame.size.height);
    self.view.frame = leftViewRect;
    [self adjustCoverView];
}

-(void)adjustCoverView{
    CGSize coverImageSize = self.coverImageView.image.size;
    self.coverHeightConstriant.constant = self.view.frame.size.width * coverImageSize.height /  coverImageSize.width;
    self.orginCoverHeight = self.coverHeightConstriant.constant;
}



//MARK: UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y < 0){
        CGRect coverRect = CGRectMake(0, scrollView.contentOffset.y,self.coverImageView.frame.size.width, self.orginCoverHeight + (-scrollView.contentOffset.y));
        self.coverImageView.frame = coverRect;
    }
}





@end
