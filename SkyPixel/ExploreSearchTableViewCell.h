//
//  ExploreSearchTableViewCell.h
//  SkyPixel
//
//  Created by Xie kesong on 12/16/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Contacts/Contacts.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ExploreSearchTableViewCell : UITableViewCell

//model
@property (strong, nonatomic) CLPlacemark* placeMark;

-(void)setPlaceMark:(CLPlacemark *)placeMark;

+(NSString*)getAddressFromPlaceMark: (CLPlacemark*) placeMark;

@end
