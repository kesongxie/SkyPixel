//
//  ProfileTableViewCell.m
//  SkyPixel
//
//  Created by Xie kesong on 12/21/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ProfileTableViewCell.h"
#import "UIImageView+ProfileAvator.h"
#import "PlayView.h"
#import "Utility.h"


@interface ProfileTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewThumbNailHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (weak, nonatomic) IBOutlet UIImageView *pauseIcon;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *playIconImageView;

//video player properties
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (strong, nonatomic) AVPlayerItem* playerItem;
@property (strong, nonatomic) AVPlayer* player;
@property (strong, nonatomic) NSString* payerItemContext;
@property (strong, nonatomic) CKAsset* videoAsset;
@property (nonatomic) BOOL resetting;
@property (nonatomic) BOOL needsResumeSettingVideo;
@property (nonatomic) BOOL isVideoPlaying;
@property (nonatomic) BOOL isVideoFinisedDownloading;

-(void)previewImageViewTapped: (UITapGestureRecognizer*)tap;

@end

@implementation ProfileTableViewCell


-(void)dealloc{
    [self resetPlayer];
}

-(void)setVideoStream:(VideoStream *)videoStream{
    _videoStream = videoStream;
    self.playerView.image = self.videoStream.thumbImage;
    self.previewThumbNailHeightConstraint.constant = [UIScreen mainScreen].bounds.size.width * self.videoStream.height / self.videoStream.width;
    self.titleLabel.text = self.videoStream.title;
    
    //add tap gesture recognizer
    UITapGestureRecognizer* previewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(previewImageViewTapped:)];
    [self addGestureRecognizer:previewTap];
}

-(void)previewImageViewTapped: (UITapGestureRecognizer*)tap{
    if(!self.isVideoPlaying){
        [self.overlayView setHidden:YES];
        if(!self.isVideoFinisedDownloading){
            [self.playIconImageView setHidden:YES];
            self.playerView.image = [[UIImage alloc]init];
            [self.activityIndicator startAnimating];
            //load the video
            [self.videoStream loadVideoAsset:^(CKAsset *videoAsset, NSError *error) {
                self.isVideoFinisedDownloading = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!self.resetting){
                        [self.activityIndicator stopAnimating];
                        [self readyLoadingVideo: videoAsset];
                    }
                });
            }];
        }else{
            [self.pauseIcon setHidden:YES];
            [self.player play];
            self.isVideoPlaying = YES;
        }
    }else{
        //pasue the video
        [self.overlayView setHidden:NO];
        [self.player pause];
        [self.pauseIcon setHidden:NO];
        self.isVideoPlaying = NO;
    }
}



//MARK: player

- (NSURL *)videoURL: (NSURL*)fileURL {
    return [self createHardLinkToVideoFile: fileURL];
}

//returns a hard link, so as not to maintain another copy of the video file on the disk
- (NSURL *)createHardLinkToVideoFile: (NSURL*)fileURL {
    NSError *err;
    NSURL* hardURL = [fileURL URLByAppendingPathExtension:@"mp4"];
    if (![hardURL checkResourceIsReachableAndReturnError:nil]) {
        if (![[NSFileManager defaultManager] linkItemAtURL: fileURL toURL: hardURL error:&err]) {
            // if creating hard link failed it is still possible to create a copy of self.asset.fileURL and return the URL of the copy
        }
    }
    return hardURL;
}

-(void) didPlayToEnd:(NSNotification*)notification{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
    self.isVideoPlaying = YES;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &_payerItemContext) {
        dispatch_async(dispatch_get_main_queue(),^{
            if ((self.player.currentItem != nil) &&
                ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
                [self.activityIndicator stopAnimating];
                [self.player play];
                self.isVideoPlaying = YES;
            }
        });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    return;
}


-(void)readyLoadingVideo: (CKAsset*)videoAsset{
    NSURL* viedoURL = [self videoURL:videoAsset.fileURL];
    AVAsset* asset = [AVAsset assetWithURL:viedoURL];
    NSArray* assetKeys = @[@"playable", @"hasProtectedContent"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(didPlayToEnd:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
    self.playerItem = [[AVPlayerItem alloc] initWithAsset: asset automaticallyLoadedAssetKeys:assetKeys];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew  context: &_payerItemContext];
    // Associate the player item with the player
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    self.playerView.player = self.player;
}

-(void)resetPlayer{
    [self.playerItem removeObserver:self forKeyPath:@"status" context:&_payerItemContext];
    [self.player pause];
}






@end
