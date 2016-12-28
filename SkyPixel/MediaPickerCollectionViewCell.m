//
//  MediaPickerCollectionViewCell.m
//  SkyPixel
//
//  Created by Xie kesong on 12/27/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//


#import "MediaPickerCollectionViewCell.h"

@interface MediaPickerCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@end

@implementation MediaPickerCollectionViewCell

-(void)setImage:(UIImage *)image{
    _image = image;
    self.previewImageView.image = self.image;
}

@end
