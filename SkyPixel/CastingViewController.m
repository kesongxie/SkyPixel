//
//  CastingViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/12/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import  <CoreLocation/CoreLocation.h>
#import "CastingViewController.h"
#import "PlayView.h"

@interface CastingViewController()

//@property (strong, nonatomic)  PlayerView *playerView;

@property (weak, nonatomic) IBOutlet PlayerView *playerView;

@property (strong, nonatomic) AVPlayerItem* playerItem;

@property (strong, nonatomic) AVPlayer* player;

@property (weak, nonatomic) IBOutlet UIImageView *playIconImageView;

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;

@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;

@property (weak, nonatomic) IBOutlet UIButton *locationBtn;

@property (strong, nonatomic) NSString* payerItemContext;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *liveIcon;

@property (weak, nonatomic) IBOutlet UILabel *viewStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *viewCountsLabel;


//update the user information, such as fullname, avator
-(void) updateUI;

////update video info, such as title
//-(void) updateStreamInfo;

-(void)didPlayToEnd:(NSNotification*)notification;


@end

@implementation CastingViewController

- (IBAction)backBtnTapped:(UIBarButtonItem *)sender {
    [self.player pause];
    [self resetPlayer];
    [self performSegueWithIdentifier:@"backFromCastingViewController" sender:self];
}


-(void) viewDidLoad{
    [super viewDidLoad];
    if(self.asset){
        self.scrollView.alwaysBounceVertical = YES;
        NSArray* assetKeys = @[@"playable", @"hasProtectedContent"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(didPlayToEnd:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
        self.playerItem = [[AVPlayerItem alloc] initWithAsset:self.asset automaticallyLoadedAssetKeys:assetKeys];
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew  context: &_payerItemContext];
        // Associate the player item with the player
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        self.playerView.player = self.player;
        [self updateUI];
        CLGeocoder* geoCoder = [[CLGeocoder alloc]init];
        [geoCoder reverseGeocodeLocation:self.videoStream.location completionHandler:^(NSArray* placemarks, NSError* error){
            if(error == nil){
                CLPlacemark* placeMark = placemarks.lastObject;
                [self.locationBtn setTitle: placeMark.name forState:UIControlStateNormal];
            }
        }];
    }
}

-(void) didPlayToEnd:(NSNotification*)notification{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}


-(void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self adjustVideoFrame];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString* count = self.viewCountsLabel.text;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [formatter numberFromString:count];
    NSInteger newCount = myNumber.intValue + 1;
    self.viewCountsLabel.text = [NSString stringWithFormat: @"%ld", (long)newCount];
}


-(void) updateUI{
    if([self.videoStream isLive]){
        self.title = @"LIVE NOW";
        [self.liveIcon setHidden:NO];
        self.viewStatusLabel.text = @"PEOPLE VIEWING";
        
    }
    self.fullnameLabel.text = self.user.fullname;
    NSData* imageData = [[NSData alloc]initWithContentsOfURL:self.user.avatorUrl];
    UIImage* avator = [[UIImage alloc]initWithData:imageData];
    self.avatorImageView.image = avator;
    self.avatorImageView.layer.cornerRadius = self.avatorImageView.frame.size.height / 2;
    self.avatorImageView.clipsToBounds = YES;
    self.videoTitleLabel.text = self.videoStream.title;

}




-(void) adjustVideoFrame{
    self.videoHeightConstraint.constant = self.view.frame.size.width * self.asset.tracks.firstObject.naturalSize.height / self.asset.tracks.firstObject.naturalSize.width;
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
