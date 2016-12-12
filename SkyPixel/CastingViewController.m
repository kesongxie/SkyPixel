//
//  CastingViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/12/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//


#import "CastingViewController.h"
#import "PlayView.h"

@interface CastingViewController()

@property (weak, nonatomic) IBOutlet PlayerView *playerView;

@property (strong, nonatomic) AVPlayerItem* playerItem;

@property (strong, nonatomic) AVPlayer* player;

@property (weak, nonatomic) IBOutlet UIImageView *playIconImageView;


@property (strong, nonatomic) NSString* payerItemContext;

@end


@implementation CastingViewController

- (IBAction)backBtnTapped:(UIBarButtonItem *)sender {
    [self.player pause];
    [self resetPlayer];
    [self performSegueWithIdentifier:@"backFromCastingViewController" sender:self];
}


-(void) viewDidLoad{
    if(self.asset){
        NSArray* assetKeys = @[@"playable", @"hasProtectedContent"];
        self.playerItem = [[AVPlayerItem alloc] initWithAsset:self.asset automaticallyLoadedAssetKeys:assetKeys];
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew  context: &_payerItemContext];
        // Associate the player item with the player
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        self.playerView.player = self.player;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &_payerItemContext) {
        dispatch_async(dispatch_get_main_queue(),^{
            if ((self.player.currentItem != nil) &&
                ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
                [self.playIconImageView setHidden:YES];
                [self.player play];
            }
        });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    return;
    
}


-(void)resetPlayer{
    [self.playerItem removeObserver:self forKeyPath:@"status" context:&_payerItemContext];
    [self.player pause];
}

@end
