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
#import "AppDelegate.h"
#import "UIImageView+ProfileAvator.h"
#import "PlayView.h"
#import "Utility.h"


static NSString* const FavorIconWhite = @"favor-icon";
static NSString* const FavorIconRed = @"favor-icon-red";

@interface ProfileTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewThumbNailHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (weak, nonatomic) IBOutlet UIImageView *pauseIcon;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *playIconImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

//video player properties
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (strong, nonatomic) AVPlayerItem* playerItem;
@property (strong, nonatomic) AVPlayer* player;
@property (strong, nonatomic) NSString* playerItemContext;
@property (strong, nonatomic) CKAsset* videoAsset;
@property (nonatomic) BOOL resetting;
@property (nonatomic) BOOL needsResumeSettingVideo;
@property (nonatomic) BOOL isVideoPlaying;
@property (nonatomic) BOOL isVideoFinisedDownloading;
@property (nonatomic) BOOL isVideoDownloading;





//pinFooterView properties
@property (weak, nonatomic) IBOutlet UIStackView *favorWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *favorIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *favorCountLabel;
@property (weak, nonatomic) IBOutlet UIStackView *commentWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIStackView *optionWrapperView;

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
    [self updatePinBottomViewUI];
    [self addTapGesture];
}


-(void)updatePinBottomViewUI{
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CKRecordID* loggedInReferenceId = [delegate.loggedInRecord recordID];
    CKReference* loggedInReference = [[CKReference alloc]initWithRecordID:loggedInReferenceId action:CKReferenceActionNone];
    //update the favor icon wrapper view
    UIImage* heartIconImage;
    if([self.videoStream.favorUserList containsObject:loggedInReference]){
        heartIconImage = [UIImage imageNamed: FavorIconRed];
    }else{
        heartIconImage =  [UIImage imageNamed: FavorIconWhite];
    }
    self.favorIconImageView.image = heartIconImage;
    NSNumber* favorCount = [NSNumber numberWithInteger:self.videoStream.favorUserList.count];
    self.favorCountLabel.text = [[NSNumberFormatter alloc]stringFromNumber:favorCount];
    
    //update the commnet wrapper view
    NSNumber* commentCount = [NSNumber numberWithInteger:self.videoStream.commentReferenceList.count];
    self.commentCountLabel.text = [[NSNumberFormatter alloc]stringFromNumber:commentCount];
    
}



-(void)addTapGesture{
    //add tap gesture recognizer
    UITapGestureRecognizer* previewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(previewImageViewTapped:)];
    [self.containerView addGestureRecognizer:previewTap];
    
    //add tap gesture for the icon
    UITapGestureRecognizer* favorTapped = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(favorTapped:)];
    [self.favorIconImageView addGestureRecognizer:favorTapped];
    
    //add tap gesture for the comment wrapper view
    UITapGestureRecognizer* commentWrapperTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentWrapperViewTapped:)];
    [self.commentWrapperView addGestureRecognizer:commentWrapperTapGesture];
    
    //add tap gesture for favorWrapperView
    UITapGestureRecognizer* favorWrapperTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(favorWrapperViewTapped:)];
    [self.favorWrapperView addGestureRecognizer:favorWrapperTapGesture];
    
    
    //add tap gesture to the cell
    UITapGestureRecognizer* cellTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cellTapped:)];
    [self.titleLabel addGestureRecognizer:cellTapGesture];

}


-(void)previewImageViewTapped: (UITapGestureRecognizer*)tap{
    if(!self.isVideoPlaying){
        [self.overlayView setHidden:YES];
        if(!self.isVideoFinisedDownloading && !self.isVideoDownloading){
            self.isVideoDownloading = YES;
            [self.playIconImageView setHidden:YES];
            self.playerView.image = [[UIImage alloc]init];
            [self.activityIndicator startAnimating];
            //load the video
            [self resetPlayer];
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
    if (context == &_playerItemContext) {
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
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew  context: &_playerItemContext];
    // Associate the player item with the player
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    self.playerView.player = self.player;
}

-(void)resetPlayer{
    [self.playerItem removeObserver:self forKeyPath:@"status" context:&_playerItemContext];
    [self.player pause];
}


//MARK: - Tap selector

-(void)cellTapped: (UITapGestureRecognizer*)gesture{
    NSDictionary* userInfo = @{VideoDetailKey: self.videoStream};
    NSNotification* notification = [[NSNotification alloc]initWithName:PresentVideoDetailNotificationName object:self  userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}



-(void)favorTapped: (UITapGestureRecognizer*)gesture{
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CKRecordID* loggedInReferenceId = [delegate.loggedInRecord recordID];
    CKReference* loggedInReference = [[CKReference alloc]initWithRecordID:loggedInReferenceId action:CKReferenceActionDeleteSelf];
    __block UIImage* heartIconImage;
    __block NSNumber* count = [[NSNumberFormatter alloc]numberFromString:self.favorCountLabel.text];
    if([self.videoStream.favorUserList containsObject:loggedInReference]){
        //delete favor
        [self deleteFavorForUserReferenceInVideoStream:loggedInReference videoStream:self.videoStream completionHandler:^{
            heartIconImage = [UIImage imageNamed: FavorIconWhite];
            count = [NSNumber numberWithInteger:[count integerValue] - 1];
            self.favorIconImageView.image = heartIconImage;
            self.favorCountLabel.text = [[NSNumberFormatter alloc] stringFromNumber:count];
        }];
        
    }else{
        //add favor
        [self addFavorForUserReferenceInVideoStream:loggedInReference videoStream:self.videoStream completionHandler:^{
            heartIconImage = [UIImage imageNamed: FavorIconRed];
            count = [NSNumber numberWithInteger:[count integerValue] + 1];
            self.favorIconImageView.image = heartIconImage;
            self.favorCountLabel.text = [[NSNumberFormatter alloc] stringFromNumber:count];
        }];
    }
}

-(void)deleteFavorForUserReferenceInVideoStream: (CKReference*) userReference videoStream: (VideoStream*) videoStream completionHandler: (void (^)(void)) callBack{
    [videoStream deleteFavorUser:userReference completionHandler:^(CKRecord *videoRecord, NSError *error) {
        //update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            callBack();
        });
    }];
}



-(void)addFavorForUserReferenceInVideoStream: (CKReference*) userReference videoStream: (VideoStream*) videoStream completionHandler: (void (^)(void)) callBack{
    [videoStream addFavorUser:userReference completionHandler:^(CKRecord *videoRecord, NSError *error) {
        //update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            callBack();
        });
    }];
}

-(void)favorWrapperViewTapped: (UITapGestureRecognizer*)gesture{
    //segue to the favor list view controller
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FavorUserListViewController* favorUserListVC= (FavorUserListViewController*)[storyboard instantiateViewControllerWithIdentifier:@"FavorUserListViewController"];
    if(favorUserListVC){
        favorUserListVC.favorUserList = self.videoStream.favorUserList;
        //notify to ProfileTableViewController to present the favorUserListVC
        NSDictionary* userInfo = @{FavorUserListVCKey : favorUserListVC};
        NSNotification* notification = [[NSNotification alloc]initWithName:PresentFavorListNotificationName object:self  userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    }
}


-(void)commentWrapperViewTapped: (UITapGestureRecognizer*)gesture{
    //show a new segue
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentListViewController* commentListVC = (CommentListViewController*)[storyboard instantiateViewControllerWithIdentifier:@"CommentListViewController"];
    if(commentListVC){
        commentListVC.videoStream = self.videoStream;
        //notify to ProfileTableViewController to present the favorUserListVC
        NSDictionary* userInfo = @{CommentUserListVCKey : commentListVC};
        NSNotification* notification = [[NSNotification alloc]initWithName:PresentCommentListNotificationName object:self  userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}


@end
