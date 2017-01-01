//
//  CoreConstant.h
//  SkyPixel
//
//  Created by Xie kesong on 12/29/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//


#import <Foundation/Foundation.h>

//MARK: - notification name constant
/*! @brief The notification name for the notification after the sharing finished */
static NSString *const FinishedSharingPostNotificationName = @"FinishedSharingPostNotification";

/*! @brief The notification name for the notification after a given shot device is picked */
static NSString *const FinishedPickingShotDeviceNotificationName = @"FinishedPickingShotDevice";


/*! @brief The notification name for detecting the player has played to its end */
static NSString *const AVPlayerItemDidPlayToEndTimeNotificationName = @"AVPlayerItemDidPlayToEndTimeNotification";

/*! @brief The notification name for the user finishing the location selection */
static NSString *const LocationSelectedNotificationName = @"LocationSelected";

/*! @brief The notification name for notifying that the search bar should become active */
static NSString *const SearchBarShouldBecomeActiveNotificationName = @"SearchBarShouldBecomeActive";

/*! @brief The notification name for notifying that the main conview should disappear */
static NSString *const MainViewShouldDisappearNotificationName = @"mainViewShouldDisappear";

/*! @brief The notification name for notifying that the user is deleting post */
static NSString *const UserDidDeletePostNotificationName = @"mainViewShouldDisappear";



//MARK: - notification user info constant
/*! @brief The userinfo key for the FinishedSharingPostNotificationName notification, the value is a VideoStream */
static NSString *const FinishedSharingPostVideoStreamInfoKey = @"FinishedSharingPostVideoStreamInfo";

/*! @brief The userinfo key for the FinishedPickingShotDeviceNotificationName notification, the value is a ShotDevice */
static NSString *const SelectedShotDevicesNotificationUserInfoKey = @"SelectedShotDevices";

/*! @brief The userinfo key for the LocationSelectedNotificationName notification, the value is a CLLocation */
static NSString *const LocationSelectedLocationInfoKey = @"location";

/*! @brief The userinfo key for the LocationSelectedNotificationName notification, the value is a NSString */
static NSString *const LocationSelectedTitleKey = @"title";

/*! @brief The userinfo key for the LocationSelectedNotificationName notification, the value is a NSString */
static NSString *const LocationSelectedSubTitleKey = @"subtitle";

/*! @brief The userinfo key for the UserDidDeletePostNotificationName notification, the value is a VideoStream */
static NSString *const DeletedVideoStreamKey = @"DeletedVideoStream";




//MARK: - storyboard constant
static NSString *const MainStoryboardName = @"Main";
static NSString *const ChooseDeviceNavigationControllerIden = @"ChooseDeviceNavigationController";
static NSString *const PostNavigationControllerIden = @"PostNavigationController";
static NSString *const ProfileCollectionViewControllerIden = @"ProfileCollectionViewController";
static NSString *const ShotDetailViewControllerIden = @"ShotDetailViewController";





