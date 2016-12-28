//
//  LocationSearchTableViewCell.m
//  SkyPixel
//
//  Created by Xie kesong on 12/16/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationSearchTableViewCell.h"

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
    NSDictionary* addr = placeMark.addressDictionary;
    NSString* street = addr[@"Street"] != nil ? [NSString stringWithFormat:@"%@, ", addr[@"Street"]] : @"";
    NSString* subLocality = addr[@"SubLocality"] != nil ? [NSString stringWithFormat:@"%@, ", addr[@"SubLocality"]] : @"";
    NSString* state = addr[@"State"] != nil ? [NSString stringWithFormat:@"%@, ", addr[@"State"]] : @"";
    NSString* postCode = addr[@"ZIP"] != nil ? [NSString stringWithFormat:@"%@, ", addr[@"ZIP"]] : @"";
    NSString* country = addr[@"Country"] != nil ? [NSString stringWithFormat:@"%@", addr[@"Country"]] : @"";
    return [NSString stringWithFormat:@"%@%@%@%@%@", street,subLocality, state, postCode,country];
}

@end
