//
//  MediaPickerCollectionViewCell.h
//  SkyPixel
//
//  Created by Xie kesong on 12/27/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface MediaPickerCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *selectedContainerAccessoryView;

/*! @brief Thumbnail preview image associate with the video/cell */
@property (strong, nonatomic) UIImage *image;

/*! @brief The PHAsset associate with the video/cell */
@property (strong, nonatomic) PHAsset *asset;

@end
