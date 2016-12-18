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


typedef enum ExpandHeaderOption {HeaderExpandDefaultOption, HeaderExpandNoEntryFoundOption} HeaderExpandOpton;

@interface ExploreSearchTableViewController : UITableViewController<UISearchResultsUpdating, UISearchBarDelegate>

@end
