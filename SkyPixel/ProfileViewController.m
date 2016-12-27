//
//  ProfileViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/25/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "UIImageView+ProfileAvator.h"
#import "HorizontalSlideInAnimator.h"
#import "ProfileHeaderView.h"

static CGFloat const CollectionViewMarginHorizontalSize = 20;


@interface ProfileViewController()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverHeightConstriant;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (nonatomic) CGFloat orginCoverHeight;

@property (weak, nonatomic) IBOutlet UICollectionView *postCollectionView;

@end

@implementation ProfileViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
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
    self.followBtn.layer.cornerRadius = 3.0;
    
    //collectionview
    self.postCollectionView.delegate = self;
    self.postCollectionView.dataSource = self;
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
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



-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    HorizontalSlideInAnimator* animator = [[HorizontalSlideInAnimator alloc] init];
    return animator;
}

//MARK: - CollectionViewDelegate, CollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 4;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionPostCell" forIndexPath:indexPath];
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    ProfileHeaderView* headerView = (ProfileHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileHeaderView" forIndexPath:indexPath];
    
    return headerView;
}



-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (self.view.frame.size.width - 3 * CollectionViewMarginHorizontalSize) / 2;
    return CGSizeMake(width, width + 60);
}





-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, CollectionViewMarginHorizontalSize, 0, CollectionViewMarginHorizontalSize);
}

@end
