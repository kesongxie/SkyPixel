//
//  ProfileTableViewCell.h
//  SkyPixel
//
//  Created by Xie kesong on 12/21/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoStream.h"
#import "FavorUserListViewController.h"
#import "CommentListViewController.h"


static NSString* const PresentFavorListNotificationName = @"PresentFavorListNotificationName";
static NSString* const FavorUserListVCKey = @"FavorUserListVCKey";
static NSString* const PresentCommentListNotificationName = @"PresentCommentListNotificationName";
static NSString* const CommentUserListVCKey = @"CommentUserListVCKey";
static NSString* const PresentVideoDetailNotificationName = @"PresentVideoDetailNotificationName";
static NSString* const VideoDetailKey = @"VideoDetailKey";


@interface ProfileTableViewCell : UITableViewCell

@property (strong,  nonatomic) VideoStream* videoStream;

@end
