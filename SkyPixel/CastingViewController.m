//
//  CastingViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/12/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import  <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "CastingViewController.h"
#import "PlayView.h"
#import "FavorUserListTableViewController.h"
#import "CommentListViewController.h"

static NSString* const FavorIconWhite = @"favor-icon";
static NSString* const FavorIconRed = @"favor-icon-red";

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

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


//update the user information, such as fullname, avator
-(void)updateUI;

-(void)didPlayToEnd:(NSNotification*)notification;

//this is function is responsible for updating the favor and comment count
-(void)updatePinBottomViewUI;


-(void)favorTapped: (UITapGestureRecognizer*)gesture;


//remove the given user reference form the userFavorList of referenList in video stream
-(void)addFavorForUserReferenceInVideoStream: (CKReference*) userReference videoStream: (VideoStream*) videoStream completionHandler: (void (^)(void)) callBack;

//add the given user reference to the userFavorList of referenList in video stream
-(void)deleteFavorForUserReferenceInVideoStream: (CKReference*) userReference videoStream: (VideoStream*) videoStream completionHandler: (void (^)(void)) callBack;
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
        UITapGestureRecognizer* commentWrapperTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentWrapperViewTapped:)];
        [self.commentWrapperView addGestureRecognizer:commentWrapperTapGesture];
        
        //add tap gesture for favorWrapperView
        UITapGestureRecognizer* favorWrapperTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(favorWrapperViewTapped:)];
        [self.favorWrapperView addGestureRecognizer:favorWrapperTapGesture];
        

    }
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
    [self updatePinBottomViewUI];
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
    self.descriptionLabel.text = self.videoStream.description;
    if(self.descriptionLabel.text.length == 0){
        self.descriptionLabel.text = @"No description available";
        self.descriptionLabel.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1]; //lighter gray
    }
    [self updatePinBottomViewUI];
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
    FavorUserListTableViewController* favorListTVC = (FavorUserListTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"FavorUserListTableViewController"];
    if(favorListTVC){
        favorListTVC.favorUserList = self.videoStream.favorUserList;
        [self.navigationController pushViewController:favorListTVC animated:YES];
    }
}


-(void)commentWrapperViewTapped: (UITapGestureRecognizer*)gesture{
    //show a new segue
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentListViewController* commentListVC = (CommentListViewController*)[storyboard instantiateViewControllerWithIdentifier:@"CommentListViewController"];
    if(commentListVC){
        commentListVC.videoStream = self.videoStream;
//        commentListVC.commentReferenceList = self.videoStream.commentReferenceList;
        [self.navigationController pushViewController:commentListVC animated:YES];
    }
}



-(void) didPlayToEnd:(NSNotification*)notification{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
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
