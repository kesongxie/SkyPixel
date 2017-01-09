//
//  CastingViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/12/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import  <CoreLocation/CoreLocation.h>
#import "CoreConstant.h"
#import "AppDelegate.h"
#import "ShotDetailViewController.h"
#import "PlayView.h"
#import "FavorUserListViewController.h"
#import "CommentListViewController.h"
#import "ProfileCollectionViewController.h"
#import "HorizontalSlideInAnimator.h"
#import "ShotDetailNavigationController.h"
#import "SkyCastNavigationViewController.h"
#import "ProfileCollectionViewController.h"
#import "VideoStream+Comparison.h"

//constants
static NSString *const FavorIconWhite = @"favor-icon";
static NSString *const FavorIconRed = @"favor-icon-red";
static NSString *const ServerHostURL = @"https://appr.tc";

static NSInteger const MaximumNumberOfVideoLoadingTrial = 50;

@interface ShotDetailViewController()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *liveIcon;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewCountsLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoHeightConstraint;
//Live video stream
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *remoteUserView;

//pinFooterView properties
@property (weak, nonatomic) IBOutlet UIView *pinFooterView;
@property (weak, nonatomic) IBOutlet UIStackView *favorWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *favorIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *favorCountLabel;
@property (weak, nonatomic) IBOutlet UIStackView *commentWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIStackView *optionWrapperView;
@property (weak, nonatomic) IBOutlet UIView *postNotExistedView;

//video player properties
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIImageView *pauseIcon;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *playIconImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) NSString *playerItemContext;
@property (strong, nonatomic) HorizontalSlideInAnimator *animator;
@property (nonatomic) NSInteger numberOfVideoLoadingTrial;

//flags for monitoring video states
@property (nonatomic) BOOL isViewVisible;
@property (nonatomic) BOOL viewControllerWillDeallocate;
@property (nonatomic) BOOL isVideoPaused;
@property (nonatomic) BOOL isVideoFinishedLoading;
@property (nonatomic) BOOL isShotNotExisted;

//Live video stream
@property (strong, nonatomic) RTCVideoTrack *remoteUserVideoTrack;
@property (strong, nonatomic) ARDAppClient *client;
@property (strong, nonatomic) NSString *userLiveChannelURL;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteVideoViewHeightConstraint;


/**
 update the user information, such as fullname, avator, etc
 */
-(void)updateUI;

/**
 notification when the video finished playing
 */
-(void)didPlayToEnd:(NSNotification*)notification;

/**
this is function is responsible for updating the favor and comment count
*/
-(void)updatePinBottomViewUI;

/**
 add gesture to views
*/
-(void)addTapGesture;

-(void)favorTapped: (UITapGestureRecognizer*)gesture;

-(void)playerViewTapped: (UITapGestureRecognizer*)gesture;

/**
 pause the video playing after loading, triggered while the user tapped the player view
 */
-(void)pausePlaying;

/**
 resume the video playing when the video is paused
 */
-(void)resumePlaying;

/**
 add the given user reference to the userFavorList of referenList in video stream
 */
-(void)favorForUserReferenceInVideoStream: (CKReference*) userReference videoStream: (VideoStream*) videoStream completionHandler: (void (^)(void)) callBack;

/**
 remove the given user reference form the userFavorList of referenList in video stream
 */
-(void)deleteFavorForUserReferenceInVideoStream: (CKReference*) userReference videoStream: (VideoStream*) videoStream completionHandler: (void (^)(void)) callBack;

/**
 Check whether this is the current loggedin user's shot
 */
-(BOOL)isCurrentUserShot;

/**
 Delete the shot
 */
-(void)deleteShot: (void(^)(CKRecordID *recordId, NSError *error))callback;


/**
 show the view indicate the post does not exist, the scorllView and pinFooterView will set to hidden as well
 */
-(void)showShotNotExistedView;

/**
 adjust the UI after a shot is deleted
 */
-(void)userDidDeletePost: (NSNotification *)notification;

@end

@implementation ShotDetailViewController

-(IBAction)backBtnTapped:(UIBarButtonItem *)sender {
    self.viewControllerWillDeallocate = YES;
    [self resetPlayer];
    if([self.navigationController isKindOfClass:[ShotDetailNavigationController class]]){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if([self.navigationController isKindOfClass:[SkyCastNavigationViewController class]]){
         [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePost:) name:UserDidDeletePostNotificationName object:nil];
    
    if(self.videoStream != nil){
        [self updateUI];
        //convert latitude and longitude to human-readable string
        CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
        [geoCoder reverseGeocodeLocation:self.videoStream.location completionHandler:^(NSArray *placemarks, NSError *error){
            if(error == nil){
                CLPlacemark *placeMark = placemarks.lastObject;
                [self.locationBtn setTitle: placeMark.name forState:UIControlStateNormal];
            }
        }];
    }
    //load asset
    [self.activityIndicator startAnimating];
    [self.videoStream loadVideoAsset:^(CKAsset *videoAsset, NSError *error) {
        self.numberOfVideoLoadingTrial += 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!self.viewControllerWillDeallocate){
                [self readyLoadingVideo: videoAsset];
            }
            
        });
    }];
    [self addTapGesture];
    [self.remoteUserView setDelegate:self];
}

-(void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self adjustVideoFrame];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.pinFooterView.frame.size.height, 0);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updatePinBottomViewUI];
    self.isViewVisible = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.player setMuted:YES];
    if(self.isVideoFinishedLoading && !self.isVideoPaused){
        [self resumePlaying];
    }
    
    //Connect to the live user
    [self disconnect];
    self.client = [[ARDAppClient alloc] initWithDelegate:self];
    [self.client setServerHostUrl:ServerHostURL];
    
//    self.userLiveChannelURL = [NSString stringWithFormat:@"%@/r/%@", ServerHostURL, self.videoStream.record.recordID.recordName];
    
    self.userLiveChannelURL = @"xie234";
    [self.client connectToRoomWithId:self.userLiveChannelURL options:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isViewVisible = NO;
    [self.player setMuted:YES];
}


-(void)showShotNotExistedView{
    [self.postNotExistedView setHidden:NO];
    [self.view bringSubviewToFront:self.postNotExistedView];
}

-(void) updateUI{
    if([self.videoStream isLive]){
        self.title = NSLocalizedString(@"LIVE NOW", @"live video");
        [self.liveIcon setHidden:NO];
        self.viewStatusLabel.text = NSLocalizedString(@"PEOPLE VIEWING", @"viewing count");
    }
    self.fullnameLabel.text = self.videoStream.user.fullname;
    self.avatorImageView.image = self.videoStream.user.thumbImage;
    self.avatorImageView.layer.cornerRadius = self.avatorImageView.frame.size.height / 2;
    self.avatorImageView.clipsToBounds = YES;
    self.videoTitleLabel.text = self.videoStream.title;
    self.descriptionLabel.text = self.videoStream.description;
    self.viewCountsLabel.text = self.videoStream.view.stringValue;
    if(self.descriptionLabel.text.length == 0){
        self.descriptionLabel.text = NSLocalizedString(@"No description available", @"default message");
        self.descriptionLabel.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1]; //lighter gray for default message
    }
    [self updatePinBottomViewUI];
}

-(void)updatePinBottomViewUI{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CKRecordID *loggedInReferenceId = [delegate.loggedInRecord recordID];
    CKReference *loggedInReference = [[CKReference alloc]initWithRecordID:loggedInReferenceId action:CKReferenceActionNone];
    //update the favor icon wrapper view
    UIImage *heartIconImage;
    if([self.videoStream.favorUserList containsObject:loggedInReference]){
        heartIconImage = [UIImage imageNamed: FavorIconRed];
    }else{
        heartIconImage =  [UIImage imageNamed: FavorIconWhite];
    }
    self.favorIconImageView.image = heartIconImage;
    NSNumber *favorCount = [NSNumber numberWithInteger:self.videoStream.favorUserList.count];
    self.favorCountLabel.text = [[NSNumberFormatter alloc]stringFromNumber:favorCount];
    
    //update the commnet wrapper view
    NSNumber *commentCount = [NSNumber numberWithInteger:self.videoStream.commentReferenceList.count];
    self.commentCountLabel.text = [[NSNumberFormatter alloc]stringFromNumber:commentCount];
}

-(void)addTapGesture{
    //add tap gesture for the icon
    UITapGestureRecognizer *favorTapped = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(favorTapped:)];
    [self.favorIconImageView addGestureRecognizer:favorTapped];
    
    //add tap gesture for the comment wrapper view
    UITapGestureRecognizer *commentWrapperTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentWrapperViewTapped:)];
    [self.commentWrapperView addGestureRecognizer:commentWrapperTapGesture];
    
    //add tap gesture for favorWrapperView
    UITapGestureRecognizer *favorWrapperTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(favorWrapperViewTapped:)];
    [self.favorWrapperView addGestureRecognizer:favorWrapperTapGesture];
    
    //add tap gesture for avator image view
    UITapGestureRecognizer *avatorTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatorImageViewTapped:)];
    [self.avatorImageView addGestureRecognizer:avatorTapGesture];
    
    //add tap gesture for the container view
    UITapGestureRecognizer *containerTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerViewTapped:)];
    [self.containerView addGestureRecognizer:containerTapGesture];
    
    //add tap gesture for the optionWrapperView
    UITapGestureRecognizer *optionTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(optionWrapperViewTapped:)];
    [self.optionWrapperView addGestureRecognizer:optionTapGesture];

}


-(void)playerViewTapped: (UITapGestureRecognizer*)gesture{
    if(self.isVideoFinishedLoading && !self.isVideoPaused){
        //pasue the video
        [self pausePlaying];
    }else{
        [self resumePlaying];
    }
}

-(void)pausePlaying{
    [self.overlayView setHidden:NO];
    [self.player pause];
    [self.playIconImageView setHidden:NO];
    self.isVideoPaused = YES;
}

-(void)resumePlaying{
    [self.overlayView setHidden:YES];
    [self.player play];
    [self.playIconImageView setHidden:YES];
    [self.pauseIcon setHidden:NO];
    [UIView animateWithDuration:1.0 animations:^{
        self.pauseIcon.alpha = 0;
    } completion:^(BOOL finished) {
        [self.pauseIcon setHidden:YES];
        self.pauseIcon.alpha = 1;
    }];
    self.isVideoPaused = NO;
}

-(void)optionWrapperViewTapped: (UITapGestureRecognizer*)gesture{
    NSString* alertTitle;
    NSString* alertDescription;
    UIAlertAction* mainAction;
    NSString* mainActionTitle;
    NSString* cancelActionTitle = NSLocalizedString(@"Cancel", @"cancel main action");
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:cancelActionTitle style:UIAlertActionStyleCancel handler:nil];
    if([self isCurrentUserShot]){
        //current user's shot
        alertTitle = NSLocalizedString(@"Delete This Shot", @"delete post alert title");
        alertDescription = NSLocalizedString(@"Are you sure you want to delete this shot? All the data associated with the shot will be removed as well", @"delete post alert description");
        mainActionTitle = NSLocalizedString(@"Delete", @"delete post action");
        mainAction = [UIAlertAction actionWithTitle:mainActionTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            //delete action
            [self deleteShot:^(CKRecordID *recordId, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // VideoStream *deletedVideoStream = self.videoStream;
                    // NSDictionary *userInfo = @{DeletedVideoStreamKey: deletedVideoStream};
                    // NSNotification *notification = [[NSNotification alloc]initWithName:UserDidDeletePostNotificationName object:nil userInfo:userInfo];
                    [self resetPlayer];
                    if([self.navigationController.presentingViewController isKindOfClass:[ProfileCollectionViewController class]]){
                        //removing shots from profile
                        ProfileCollectionViewController* profileCVC = (ProfileCollectionViewController*)self.navigationController.presentingViewController;
                        [profileCVC.user removeVideoStreamRecordFromUser:self.videoStream.record];
                        [profileCVC.collectionView reloadData];
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }else{
                        //clear from the map
                        [self.navigationController popViewControllerAnimated:YES];
                        //send notification to SkyCastViewController to update the UI

                    }
                });
            }];
            
        }];
    }else{
        //otherwise
        alertTitle = NSLocalizedString(@"Report This Shot", @"report post");
        alertDescription = NSLocalizedString(@"Do you want to report this shot? A shot is considered inappropriate when it contains voilent, pornography, or misleading content", @"report post description");
        mainActionTitle = NSLocalizedString(@"Report Inappropriate", @"report post action");
        mainAction = [UIAlertAction actionWithTitle:mainActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //report action
        }];
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertDescription preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:mainAction];
    [alert addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}


-(void)favorTapped: (UITapGestureRecognizer*)gesture{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CKReference *loggedInReference = delegate.loggedInUser.reference;
    __block UIImage *heartIconImage;
    __block NSNumber *count = [[NSNumberFormatter alloc]numberFromString:self.favorCountLabel.text];
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
        [self favorForUserReferenceInVideoStream:loggedInReference videoStream:self.videoStream completionHandler:^{
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


-(void)favorForUserReferenceInVideoStream: (CKReference*) userReference videoStream: (VideoStream*) videoStream completionHandler: (void (^)(void)) callBack{
    [videoStream addFavorUser:userReference completionHandler:^(CKRecord *videoRecord, NSError *error) {
        //update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            callBack();
        });
    }];
}

-(void)favorWrapperViewTapped: (UITapGestureRecognizer*)gesture{
    //segue to the favor list view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:MainStoryboardName bundle:nil];
    FavorUserListViewController *favorUserListVC= (FavorUserListViewController*)[storyboard instantiateViewControllerWithIdentifier:FavorUserListViewControllerIden];
    if(favorUserListVC){
        favorUserListVC.favorUserList = self.videoStream.favorUserList;
        [self.navigationController pushViewController:favorUserListVC animated:YES];
    }
}


-(void)commentWrapperViewTapped: (UITapGestureRecognizer*)gesture{
    //show a new segue
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:MainStoryboardName bundle:nil];
    CommentListViewController *commentListVC = (CommentListViewController*)[storyboard instantiateViewControllerWithIdentifier:CommentListViewControllerIden];
    if(commentListVC){
        commentListVC.videoStream = self.videoStream;
        [self.navigationController pushViewController:commentListVC animated:YES];
    }
}

-(void)avatorImageViewTapped: (UITapGestureRecognizer*)gesture{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:MainStoryboardName bundle:nil];
    ProfileCollectionViewController *profileCVC = (ProfileCollectionViewController*)[storyboard instantiateViewControllerWithIdentifier:ProfileCollectionViewControllerIden];
    if(profileCVC){
        profileCVC.user = self.videoStream.user;
        profileCVC.transitioningDelegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:profileCVC animated:YES completion:nil];
        });
    }
}

-(BOOL)isCurrentUserShot{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return [self.videoStream.user.reference isEqual:appDelegate.loggedInUser.reference];
}

-(void)deleteShot: (void(^)(CKRecordID *recordId, NSError *error))callback{
    [VideoStream deleteShot:self.videoStream completionHandler:^(CKRecordID *recordId, NSError *error) {
        callback(recordId, error);
    }];
}

-(void)userDidDeletePost: (NSNotification *)notification{
    //handle UI updates after deleting
}

+(void)pushShotDetailWithVideoStream:(UINavigationController*)navigationController withVideoStream: (VideoStream*) videoStream{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:MainStoryboardName bundle:nil];
    ShotDetailViewController *castVC = (ShotDetailViewController*)[storyboard instantiateViewControllerWithIdentifier:ShotDetailViewControllerIden];
    if(castVC){
        castVC.videoStream = videoStream;
        [navigationController pushViewController:castVC animated:YES];
    }
}


//MARK: player
-(NSURL *)videoURL: (NSURL*)fileURL {
    return [self createHardLinkToVideoFile: fileURL];
}

//returns a hard link, so as not to maintain another copy of the video file on the disk
-(NSURL *)createHardLinkToVideoFile: (NSURL*)fileURL {
    NSError *err;
    NSURL *hardURL = [fileURL URLByAppendingPathExtension:@"mp4"];
    if (![hardURL checkResourceIsReachableAndReturnError:nil]) {
        if (![[NSFileManager defaultManager] linkItemAtURL: fileURL toURL: hardURL error:&err]) {
            // if creating hard link failed it is still possible to create a copy of self.asset.fileURL and return the URL of the copy
        }
    }
    return hardURL;
}

-(void) didPlayToEnd:(NSNotification*)notification{
    [self.player seekToTime:kCMTimeZero];
    if(self.isViewVisible){
        [self.player play];
    }
}

-(void) adjustVideoFrame{
    if(self.videoStream.width != 0 && self.videoStream.height != 0){
        self.videoHeightConstraint.constant = self.view.frame.size.width  *self.videoStream.height / self.videoStream.width;
    }
}

-(void)readyLoadingVideo: (CKAsset*)videoAsset{
    if(videoAsset){
        NSURL *viedoURL = [self videoURL:videoAsset.fileURL];
        AVAsset *asset = [AVAsset assetWithURL:viedoURL];
        NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(didPlayToEnd:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
        self.playerItem = [[AVPlayerItem alloc] initWithAsset: asset automaticallyLoadedAssetKeys:assetKeys];
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew  context: &_playerItemContext];
        // Associate the player item with the player
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        self.playerView.player = self.player;
    }else{
        //try again
        if(self.numberOfVideoLoadingTrial < MaximumNumberOfVideoLoadingTrial){
            self.numberOfVideoLoadingTrial += 1;
            [self.videoStream loadVideoAsset:^(CKAsset *videoAsset, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self readyLoadingVideo: videoAsset];
                });
            }];
        }else{
            //media is not available
            NSLog(@"Media is not available");
        }
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &_playerItemContext) {
        dispatch_async(dispatch_get_main_queue(),^{
            if ((self.player.currentItem != nil) &&
                ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
                if(!self.isViewVisible){
                    [self.player setMuted:YES];
                }
                [self.activityIndicator stopAnimating];
                self.isVideoFinishedLoading = YES;
                if(!self.isVideoPaused){
                    [self.player play];
                }
            }
        });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    return;
}


-(void)resetPlayer{
    NSLog(@"removing obersever");
    [self.playerItem removeObserver:self forKeyPath:@"status" context:&_playerItemContext];
    self.playerItemContext = nil;
    [self.player pause];

}


//MARK: - live video stream
- (void)disconnect {
    if (self.client) {
        if (self.remoteUserVideoTrack) [self.remoteUserVideoTrack removeRenderer:self.remoteUserView];
        self.remoteUserVideoTrack = nil;
        [self.remoteUserView renderFrame:nil];
        [self.client disconnect];
    }
}


- (void)remoteDisconnected {
    if (self.remoteUserVideoTrack) [self.remoteUserVideoTrack removeRenderer:self.remoteUserView];
    self.remoteUserVideoTrack = nil;
    [self.remoteUserView renderFrame:nil];
}


//MARK: - Custom transition
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.animator = [[HorizontalSlideInAnimator alloc] init];
    return self.animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self.animator;
}

//MARK: - ARDAppClientDelegate
- (void)appClient:(ARDAppClient *)client didChangeState:(ARDAppClientState)state {
    switch (state) {
    case kARDAppClientStateConnected:
    NSLog(@"Client connected.");
    break;
    case kARDAppClientStateConnecting:
    NSLog(@"Client connecting.");
    break;
    case kARDAppClientStateDisconnected:
    NSLog(@"Client disconnected.");
    [self remoteDisconnected];
    break;
    }
}


-(void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size{
    self.remoteVideoViewHeightConstraint.constant = self.remoteUserView.frame.size.width * size.height / size.width;
}

-(void)appClient:(ARDAppClient *)client didError:(NSError *)error{
    NSLog(@"error %@", error.localizedDescription);
}

- (void)appClient:(ARDAppClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack{
    NSLog(@"did receive local track");
}


- (void)appClient:(ARDAppClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
    self.remoteUserVideoTrack = remoteVideoTrack;
    [self.remoteUserVideoTrack addRenderer:self.remoteUserView];
    

}




@end
