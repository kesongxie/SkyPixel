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

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

//pinFooterView properties
@property (weak, nonatomic) IBOutlet UIStackView *favorWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *favorIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *favorCountLabel;
@property (weak, nonatomic) IBOutlet UIStackView *commentWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIStackView *optionWrapperView;

@property (weak, nonatomic) IBOutlet UIView *containerView;

//remove the given user reference form the userFavorList of referenList in video stream
-(void)favorForUserReferenceInVideoStream: (CKReference*) userReference videoStream: (VideoStream*) videoStream completionHandler: (void (^)(void)) callBack;

//add the given user reference to the userFavorList of referenList in video stream
-(void)deleteFavorForUserReferenceInVideoStream: (CKReference*) userReference videoStream: (VideoStream*) videoStream completionHandler: (void (^)(void)) callBack;


@end

@implementation ProfileTableViewCell


-(void)setVideoStream:(VideoStream *)videoStream{
    _videoStream = videoStream;
    self.previewImageView.image = self.videoStream.thumbImage;
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
    UITapGestureRecognizer* titleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(detailTriggerTapped:)];
    
    UITapGestureRecognizer* containerTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(detailTriggerTapped:)];

    [self.titleLabel addGestureRecognizer:titleTapGesture];
    [self.containerView addGestureRecognizer:containerTapGesture];

}


//MARK: - Tap selector
-(void)detailTriggerTapped: (UITapGestureRecognizer*)gesture{
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
