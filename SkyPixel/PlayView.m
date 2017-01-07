//
//  PlayView.m
//  SkyPixel
//
//  Created by Xie kesong on 12/11/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "PlayView.h"


@implementation PlayerView

//Override the layer class, otherwise CALayer class object by default.
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end
