//
//  UIImageView+ProfileAvator.m
//  SkyPixel
//
//  Created by Xie kesong on 12/22/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "UIImageView+ProfileAvator.h"

@implementation UIImageView (ProfileAvator)

-(void)becomeAvatorProifle: (UIImage*) avator{
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.clipsToBounds = YES;
    self.image = avator;
}

@end
