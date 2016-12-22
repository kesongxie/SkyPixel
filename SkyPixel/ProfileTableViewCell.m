//
//  ProfileTableViewCell.m
//  SkyPixel
//
//  Created by Xie kesong on 12/21/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileTableViewCell.h"
#import "Utility.h"


@interface ProfileTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewThumbNailHeightConstraint;

@end

@implementation ProfileTableViewCell

-(void)setVideoStream:(VideoStream *)videoStream{
    _videoStream = videoStream;
    self.previewImageView.image = self.videoStream.thumbImage;
    self.previewThumbNailHeightConstraint.constant = [UIScreen mainScreen].bounds.size.width * self.videoStream.height / self.videoStream.width;
    self.titleLabel.text = self.videoStream.title;
}



@end
