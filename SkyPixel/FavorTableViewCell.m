//
//  FavorTableViewCell.m
//  SkyPixel
//
//  Created by Xie kesong on 12/19/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "FavorTableViewCell.h"

@interface FavorTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;

@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;

@end

@implementation FavorTableViewCell

-(void)setUser:(User *)user{
    _user = user;
    //update UI
    self.fullnameLabel.text = self.user.fullname;
    NSData* imageData = [[NSData alloc]initWithContentsOfURL:self.user.avatorUrl];
    UIImage* avator = [[UIImage alloc]initWithData:imageData];
    self.avatorImageView.image = avator;
    self.avatorImageView.layer.cornerRadius = self.avatorImageView.frame.size.width / 2;
    self.avatorImageView.clipsToBounds = YES;
}

@end
