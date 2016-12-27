//
//  ProfileHeaderView.h
//  SkyPixel
//
//  Created by Xie kesong on 12/26/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverHeightConstriant;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (nonatomic) CGFloat orginCoverHeight;
@property (nonatomic) CGPoint backBtnOrigin;
@property (weak, nonatomic) IBOutlet UILabel *shotsCountLabel;

@end
