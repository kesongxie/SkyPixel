//
//  EditPostAddDetailViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/27/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "EditPostAddDetailViewController.h"
#import "PlayView.h"
#import "LocationSearchNavigationController.h"
#import "LocationSearchTableViewController.h"
#import "ChooseDeviceNavigationController.h"
#import "ChooseDeviceViewController.h"
#import "ShotDevice.h"
#import "VideoStream.h"


static CGFloat const AdjustOffSetForKeyboardShow = 4.0;
static NSTimeInterval const AnimationTimeIntervalForKeyboardShow = 0.3;
static NSString* const MainStoryBoardName = @"Main";

@interface EditPostAddDetailViewController()<UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *muteIcon;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareBtnHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *shotByTextField;
@property (strong, nonatomic) UITextField* activeTextField;
@property (strong, nonatomic) AVPlayer* player;
@property (strong, nonatomic) AVPlayerItem* playerItem;
@property (strong, nonatomic) NSString* payerItemContext;


//inputs
@property (strong, nonatomic) CLLocation* videoLocationInput;
@property (strong, nonatomic) ShotDevice* shotDeviceInput;

@property (weak, nonatomic) IBOutlet UIView *contentView;

//control flags
@property (nonatomic) BOOL isViewVisible;
@property (nonatomic) BOOL isVideoMuted;
@property (nonatomic) BOOL isKeyboardShowing;



@end

@implementation EditPostAddDetailViewController

- (IBAction)shareBtnTapped:(UIButton *)sender {
    //ShotDetailNavigationController
    [VideoStream shareVideoStream:self.titleTextField.text ofLocation:self.videoLocationInput withDescription:self.descriptionTextField.text videoAsset:self.asset previewThumbNail:self.thumbnailImage];
    
}



-(IBAction)backBtnTapped:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setAsset:(PHAsset *)asset{
    _asset = asset;
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceVertical = YES;
    //textfield delegate
    self.titleTextField.delegate = self;
    self.locationTextField.delegate = self;
    self.descriptionTextField.delegate = self;
    self.shotByTextField.delegate = self;
    //preload location
    CLGeocoder* coder = [[CLGeocoder alloc]init];
    [coder reverseGeocodeLocation:self.asset.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(placemarks){
            if(placemarks.count > 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.videoLocationInput = self.asset.location;
                    self.locationTextField.text = placemarks.firstObject.name;
                });
            }
        }
    }];
    
    //custom notification observing
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(locationDidSelected:) name:LocationSelectedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(finishedDeviceSelection:) name:FinishedPickingShotDeviceNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(didPlayToEnd:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
    
    //keyboard notification observing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
   
    //add control event for textfield
    [self.titleTextField addTarget:self action:@selector(textFiledDidChange) forControlEvents:UIControlEventEditingChanged];
    
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoTapped:)];
    [self.containerView addGestureRecognizer:tap];
    [self updateShareBtnUI];
    [self requestPlayerItem];
    
   
}


-(void)textFiledDidChange{
    [self updateShareBtnUIAfterFieldValueChanged];
}

-(void)dealloc{
    [self resetPlayer];
}

-(void)finishedDeviceSelection:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    if(userInfo){
        ShotDevice* shotDevice = (ShotDevice*)userInfo[SelectedShotDevicesNotificationUserInfoKey];
        if(shotDevice){
            self.shotDeviceInput = shotDevice;
            self.shotByTextField.text = shotDevice.deviceName;
        }
    }else{
        self.shotDeviceInput = nil;
        self.shotByTextField.text = @"";
    }
}

-(void)locationDidSelected:(NSNotification*)notification{
    if(notification.object != self){
        return;
    }
    CLLocation* location = (CLLocation*)notification.userInfo[LocationSelectedLocationInfoKey];
    if(location != nil){
        //update
        NSString* title = (NSString*)notification.userInfo[LocationSelectedTitleKey];
        if(title != nil){
            self.videoLocationInput = location;
            self.locationTextField.text = title;
            [self.navigationController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }else{
        NSLog(@"location is nil");
    }
}

-(void)keyboardDidShow: (NSNotification*)notification{
    NSValue* value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    if(value){
        CGRect rect = value.CGRectValue;
        CGFloat keyboardHeight = rect.size.height;
        CGFloat activeTextFieldBottomY = self.activeTextField.frame.origin.y + self.shotByTextField.frame.size.height;
        if(activeTextFieldBottomY + keyboardHeight > self.view.frame.size.height){
            //adjust
            CGFloat startOrginY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
            CGFloat originShouldAdjust = self.scrollView.contentOffset.y + startOrginY -(activeTextFieldBottomY + keyboardHeight -self.view.frame.size.height) -AdjustOffSetForKeyboardShow;
            CGRect frame = CGRectMake(0, originShouldAdjust, self.view.frame.size.width, self.view.frame.size.height);
            [UIView animateWithDuration:AnimationTimeIntervalForKeyboardShow animations:^{
                self.view.frame = frame;
            } completion:^(BOOL finished) {
                self.isKeyboardShowing = NO;
            }];
        }else{
            self.isKeyboardShowing = NO;
        }
    }
}

-(void)keyboardWillHide: (NSNotification*)notification{
    CGFloat startOrginY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    CGRect frame = CGRectMake(0, startOrginY, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:AnimationTimeIntervalForKeyboardShow animations:^{
        self.view.frame = frame;
    }];
}

-(void)locationTextFieldTapped{
    UIStoryboard* storybord = [UIStoryboard storyboardWithName:MainStoryBoardName bundle:nil];
    LocationSearchNavigationController* locationSearchNVC = (LocationSearchNavigationController*)[storybord instantiateViewControllerWithIdentifier:LocationSearchNavigationControllerIden];
    if(locationSearchNVC){
        LocationSearchTableViewController* locationSearchTVC = (LocationSearchTableViewController*)locationSearchNVC.viewControllers.firstObject;
        locationSearchTVC.serachBarPresetValue = self.locationTextField.text;
        locationSearchTVC.targetForReceivingLocationSelection = self;
        [self presentViewController:locationSearchNVC animated:YES completion:nil];
    }
}
-(void)shotByTextFieldTapped{
    UIStoryboard* storybord = [UIStoryboard storyboardWithName:MainStoryBoardName bundle:nil];
    ChooseDeviceNavigationController* chooseDeviceNVC = (ChooseDeviceNavigationController*)[storybord instantiateViewControllerWithIdentifier:ChooseDeviceNavigationControllerIden];
    if(chooseDeviceNVC){
        ChooseDeviceViewController* chooseDeviceVC = (ChooseDeviceViewController*)chooseDeviceNVC.viewControllers.firstObject;
        chooseDeviceVC.preSelectedShotDevice = self.shotDeviceInput;
        [self presentViewController:chooseDeviceNVC animated:YES completion:nil];
    }

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self updatePlayerViewUI];
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, self.shareBtnHeightConstraint.constant, 0);
    self.scrollView.contentInset = inset;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.isViewVisible = YES;
}


-(void)updatePlayerViewUI{
    NSUInteger width = self.asset.pixelWidth;
    NSUInteger height = self.asset.pixelHeight;
    self.playerViewHeightConstraint.constant = self.view.frame.size.width * height / width;
}

// Share button UI and control
-(void)updateShareBtnUI{
    self.shareBtn.layer.borderColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1].CGColor;
    self.shareBtn.layer.borderWidth = 1.0;
    [self setShareBtnDisabled];
}

-(void)setShareBtnEnabled{
    self.shareBtn.alpha = 1;
    [self.shareBtn setEnabled:YES];
}

-(void)setShareBtnDisabled{
    self.shareBtn.alpha = 0.5;
    [self.shareBtn setEnabled:NO];
}

-(void)updateShareBtnUIAfterFieldValueChanged{
    if(self.videoLocationInput && self.titleTextField.text.length > 0){
        [self setShareBtnEnabled];
    }else{
        [self setShareBtnDisabled];
    }
}

-(void)requestPlayerItem{
    PHCachingImageManager* cacheManager = [[PHCachingImageManager alloc]init];
    [cacheManager requestPlayerItemForVideo:self.asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if(playerItem){
            self.playerItem = playerItem;
            [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew  context: &_payerItemContext];
            // Associate the player item with the player
            self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
            [self.player setMuted:YES];
            self.isVideoMuted = YES;
            self.playerView.player = self.player;
        }
    }];
}


-(void)videoTapped: (UITapGestureRecognizer*)gesture{
    [self.muteIcon setHidden:self.isVideoMuted];
    self.isVideoMuted = !self.isVideoMuted;
    [self.player setMuted:self.isVideoMuted];
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &_payerItemContext) {
        dispatch_async(dispatch_get_main_queue(),^{
            if ((self.player.currentItem != nil) &&
                ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
                  if(self.isViewVisible){
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
    [self.playerItem removeObserver:self forKeyPath:@"status" context:&_payerItemContext];
    [self.player pause];
}

-(void) didPlayToEnd:(NSNotification*)notification{
    [self.player seekToTime:kCMTimeZero];
    if(self.isViewVisible){
        [self.player play];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!self.isKeyboardShowing){
        [self.view endEditing:YES];
    }
}



//MARK: -UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.activeTextField = textField;
    self.isKeyboardShowing = YES;
    if(textField == self.locationTextField){
        [self.view endEditing:YES];
        [self locationTextFieldTapped];
    }else if(textField == self.shotByTextField){
        [self.view endEditing:YES];
        [self shotByTextFieldTapped];
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return true;
}


@end
