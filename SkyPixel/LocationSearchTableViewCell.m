//
//  LocationSearchTableViewCell.m
//  SkyPixel
//
//  Created by Xie kesong on 12/16/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationSearchTableViewCell.h"

static NSString *const StreetKey = @"Street";
static NSString *const SubLocalityKey = @"SubLocality";
static NSString *const StateKey = @"State";
static NSString *const ZIPKey = @"ZIP";
static NSString *const CountryKey = @"Country";







@interface LocationSearchTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeMarkName;
@property (weak, nonatomic) IBOutlet UILabel *placeAddress;

-(void) updateUI;

@end

@implementation LocationSearchTableViewCell

-(void)setPlaceMark:(CLPlacemark *)placeMark{
    if(placeMark != nil){
        _placeMark = placeMark;
        [self updateUI];
    }
}

-(void) updateUI{
    self.placeAddress.text = [LocationSearchTableViewCell getAddressFromPlaceMark:self.placeMark];
    self.placeMarkName.text = self.placeMark.name;
}


+(NSString*)getAddressFromPlaceMark: (CLPlacemark*) placeMark{
    NSDictionary *addr = placeMark.addressDictionary;
    NSString *street = addr[StreetKey] != nil ? [NSString stringWithFormat:@"%@, ", addr[StreetKey]] : @"";
    NSString *subLocality = addr[SubLocalityKey] != nil ? [NSString stringWithFormat:@"%@, ", addr[SubLocalityKey]] : @"";
    NSString *state = addr[StateKey] != nil ? [NSString stringWithFormat:@"%@, ", addr[StateKey]] : @"";
    NSString *postCode = addr[ZIPKey] != nil ? [NSString stringWithFormat:@"%@, ", addr[ZIPKey]] : @"";
    NSString *country = addr[CountryKey] != nil ? [NSString stringWithFormat:@"%@", addr[CountryKey]] : @"";
    return [NSString stringWithFormat:@"%@%@%@%@%@", street,subLocality, state, postCode,country];
}

@end
