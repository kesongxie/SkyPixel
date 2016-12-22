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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData* imageData = [[NSData alloc]initWithContentsOfURL:self.videoStream.thumbnail];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* image = [[UIImage alloc]initWithData:imageData];
            self.previewImageView.image = image;
            self.previewThumbNailHeightConstraint.constant = [UIScreen mainScreen].bounds.size.width * image.size.height / image.size.width;
            self.titleLabel.text = self.videoStream.title;

        });
    });
}



@end
