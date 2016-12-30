//
//  ProfileCollectionViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/26/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "UIImageView+ProfileAvator.h"
#import "HorizontalSlideInAnimator.h"
#import "ProfileCollectionViewController.h"
#import "ProfileHeaderView.h"
#import "PostCollectionViewCell.h"
#import "ShotDetailNavigationController.h"
#import "ShotDetailViewController.h"


static CGFloat const Space = 16;

@interface ProfileCollectionViewController()<UIViewControllerTransitioningDelegate,  UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) ProfileHeaderView *headerView;
@property (nonatomic) BOOL preferStatusBarHidden;
@property (strong, nonatomic) HorizontalSlideInAnimator *animator;

@end

@implementation ProfileCollectionViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.preferStatusBarHidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.preferStatusBarHidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}


-(BOOL)prefersStatusBarHidden{
    return self.preferStatusBarHidden;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)adjustCoverView{
    CGSize coverImageSize = self.headerView.coverImageView.image.size;
    self.headerView.coverHeightConstriant.constant = self.view.frame.size.width  *coverImageSize.height /  coverImageSize.width;
    self.headerView.orginCoverHeight = self.headerView.coverHeightConstriant.constant;
}

-(void)setHeaderView:(ProfileHeaderView *)headerView{
    _headerView =  headerView;
    [self.headerView.avatorImageView becomeAvatorProifle:self.user.thumbImage];
    self.headerView.shotsCountLabel.text = [NSString stringWithFormat:@"%i", self.user.videoStreamRecord.count];
    self.headerView.avatorImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headerView.avatorImageView.layer.borderWidth = 3.0;
    self.headerView.fullnameLabel.text = self.user.fullname;
    self.headerView.coverImageView.image = self.user.coverThumbImage;
    self.headerView.bioLabel.text = self.user.bio;
    self.headerView.followBtn.layer.cornerRadius = 3.0;
    [self.headerView.backBtn addTarget:self action:@selector(backBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.headerView.backBtnOrigin = self.headerView.backBtn.frame.origin;
    [self adjustCoverView];
}

- (void)backBtnTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//MARK: UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y < 0){
        CGRect coverRect = CGRectMake(0, scrollView.contentOffset.y,self.headerView.coverImageView.frame.size.width, self.headerView.orginCoverHeight + (-scrollView.contentOffset.y));
        self.headerView.coverImageView.frame = coverRect;
        CGRect backBtnRect = CGRectMake(self.headerView.backBtnOrigin.x, self.headerView.backBtnOrigin.y + scrollView.contentOffset.y, self.headerView.backBtn.frame.size.width, self.headerView.backBtn.frame.size.height);
        self.headerView.backBtn.frame = backBtnRect;
    }
}

//MARK: - CollectionViewDelegate, CollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.user.videoStreamRecord.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PostCollectionViewCell *cell = (PostCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionPostCell" forIndexPath:indexPath];
    
    VideoStream *videoStream = [[VideoStream alloc]initWithCKRecord:self.user.videoStreamRecord[indexPath.row]];
    cell.videoStream = videoStream;
    cell.layer.cornerRadius = 4.0;
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    ProfileHeaderView *headerView = (ProfileHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileHeaderView" forIndexPath:indexPath];
    if(self.headerView == nil){
        //set only once
        self.headerView = headerView;
    }
    return headerView;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
   ShotDetailNavigationController *shotDetailNVC = (ShotDetailNavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"ShotDetailNavigationController"];
    if(shotDetailNVC){
         VideoStream *videoStream = [[VideoStream alloc]initWithCKRecord:self.user.videoStreamRecord[indexPath.row]];
        videoStream.user = self.user;
        ShotDetailViewController *shotDetailVC = (ShotDetailViewController*)shotDetailNVC.viewControllers.firstObject;
        if(shotDetailVC){
            shotDetailVC.videoStream = videoStream;
            shotDetailNVC.transitioningDelegate = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:shotDetailNVC animated:YES completion:nil];
            });
        }
    }
}

//MARK: - CollectionViewFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (self.view.frame.size.width - 3  *Space) / 2;
    return CGSizeMake(width, width + 44);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return Space;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, Space, Space, Space);
}



//MARK: - custom transition for presentation
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.animator = [[HorizontalSlideInAnimator alloc] init];
    return self.animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self.animator;
}

@end
