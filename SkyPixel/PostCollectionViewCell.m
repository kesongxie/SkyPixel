//
//  PostCollectionViewCell.m
//  SkyPixel
//
//  Created by Xie kesong on 12/26/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "PostCollectionViewCell.h"

@interface PostCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;

@end

@implementation PostCollectionViewCell

-(void)setVideoStream:(VideoStream *)videoStream{
    self.previewImageView.image = videoStream.thumbImage;
    self.titleLabel.text = videoStream.title;
    NSString* views = NSLocalizedString(@"VIEWS", @"views on profile page post");
    self.viewsLabel.text = [NSString stringWithFormat:@"%@ %@", videoStream.view.stringValue, views];
}

@end
