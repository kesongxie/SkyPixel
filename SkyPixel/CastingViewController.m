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
#import "AppDelegate.h"

@interface CastingViewController()

@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *liveIcon;
@property (weak, nonatomic) IBOutlet UILabel *viewStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewCountsLabel;
@property (weak, nonatomic) IBOutlet UIView *pinFooterView;
@property (weak, nonatomic) IBOutlet UIStackView *favorWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *favorIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *favorCountLabel;
@property (weak, nonatomic) IBOutlet UIStackView *commentWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIStackView *optionWrapperView;
@property (strong, nonatomic) AVPlayerItem* playerItem;
@property (strong, nonatomic) AVPlayer* player;
@property (strong, nonatomic) NSString* payerItemContext;

//update the user information, such as fullname, avator
-(void)updateUI;

-(void)didPlayToEnd:(NSNotification*)notification;

//this is function is responsible for updating the favor and comment count
-(void)updatePinBottomViewUI;

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
        
        //add tap gesture for the icon
        UITapGestureRecognizer* favorTapped = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(favorTapped:)];
        [self.favorIconImageView addGestureRecognizer:favorTapped];
        
        //add tap gesture for the comment wrapper view
        UITapGestureRecognizer* commentWrapperTapped = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentWrapperTapped:)];
        [self.commentWrapperView addGestureRecognizer:commentWrapperTapped];
        
        
        //update pinFooterViewUI
        
    }
}


-(void)updatePinBottomViewUI{
    NSNumber* favorCount = [NSNumber numberWithInteger:self.videoStream.favorUserList.count];
    self.favorCountLabel.text = [[NSNumberFormatter alloc]stringFromNumber:favorCount];
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CKRecordID* loggedInReferenceId = [delegate.loggedInRecord recordID];
    CKReference* loggedInReference = [[CKReference alloc]initWithRecordID:loggedInReferenceId action:CKReferenceActionDeleteSelf];
    UIImage* heartIconImage;
    
    NSLog(@"the loggedin reference is %@", loggedInReference);
    NSLog(@"the loggedin reference list is %@", self.videoStream.favorUserList);

    if([self.videoStream.favorUserList containsObject:loggedInReference]){
        heartIconImage = [UIImage imageNamed:@"favor-icon-red"];
    }else{
        heartIconImage =  [UIImage imageNamed:@"favor-icon"];
        NSLog(@"NIL");
    }
    self.favorIconImageView.image = heartIconImage;
}



-(void)favorTapped: (UITapGestureRecognizer*)gesture{
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CKRecordID* loggedInReferenceId = [delegate.loggedInRecord recordID];
    CKReference* loggedInReference = [[CKReference alloc]initWithRecordID:loggedInReferenceId action:CKReferenceActionDeleteSelf];
    UIImage* heartIconImage;
    NSNumber* count = [[NSNumberFormatter alloc]numberFromString:self.favorCountLabel.text];
    if([self.videoStream.favorUserList containsObject:loggedInReference]){
        heartIconImage =  [UIImage imageNamed:@"favor-icon"];
        count = [NSNumber numberWithInteger:[count integerValue] - 1];
    }else{
        heartIconImage = [UIImage imageNamed:@"favor-icon-red"];
        count = [NSNumber numberWithInteger:[count integerValue] + 1];
    }
    self.favorIconImageView.image = heartIconImage;
    self.favorCountLabel.text = [[NSNumberFormatter alloc] stringFromNumber:count];
}

-(void)commentWrapperTapped: (UITapGestureRecognizer*)gesture{
    //show a new segue
    
}




-(void) didPlayToEnd:(NSNotification*)notification{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}


-(void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self adjustVideoFrame];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.pinFooterView.frame.size.height, 0);
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
    [self updatePinBottomViewUI];
    
}




-(void) adjustVideoFrame{
    self.videoHeightConstraint.constant = self.view.frame.size.width * self.asset.tracks.firstObject.naturalSize.height / self.asset.tracks.firstObject.naturalSize.width;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &_payerItemContext) {
        dispatch_async(dispatch_get_main_queue(),^{
            if ((self.player.currentItem != nil) &&
                ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
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
