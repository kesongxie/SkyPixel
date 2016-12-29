//
//  ExploreSearchTableViewController.h
//  SkyPixel
//
//  Created by Xie kesong on 12/15/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ContainerViewController.h"

static NSString* const LocationSelectedNotificationName = @"LocationSelected";
static NSString* const LocationSelectedLocationInfoKey = @"location";
static NSString* const LocationSelectedTitleKey = @"title";
static NSString* const LocationSelectedSubTitleKey = @"subtitle";
static NSString* const SearchBarShouldBecomeActiveNotificationName = @"SearchBarShouldBecomeActive";

typedef enum ExpandHeaderOption {HeaderExpandDefaultOption, HeaderExpandNoEntryFoundOption} HeaderExpandOpton;

@interface LocationSearchTableViewController : UITableViewController<UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic)  NSString* serachBarPresetValue;
@property (strong, nonatomic) UIViewController* targetForReceivingLocationSelection; //specify which object should receive the notification when a new location is selected

@end
