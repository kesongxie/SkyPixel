//
//  ChooseDeviceTableViewCell.m
//  SkyPixel
//
//  Created by Xie kesong on 12/28/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "ChooseDeviceTableViewCell.h"

@interface ChooseDeviceTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *deviceThumbImageView;

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@end


@implementation ChooseDeviceTableViewCell

-(void)setShotDevice:(ShotDevice *)shotDevice{
    _shotDevice = shotDevice;
    self.deviceNameLabel.text = self.shotDevice.deviceName;
    self.deviceThumbImageView.image = self.shotDevice.thumbnailImage;
}

@end
