//
//  ExploreSearchTableViewCell.m
//  SkyPixel
//
//  Created by Xie kesong on 12/16/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExploreSearchTableViewCell.h"

@interface ExploreSearchTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeMarkName;
@property (weak, nonatomic) IBOutlet UILabel *placeAddress;

-(void) updateUI;

@end

@implementation ExploreSearchTableViewCell

-(void)setPlaceMark:(CLPlacemark *)placeMark{
    if(placeMark != nil){
        _placeMark = placeMark;
        [self updateUI];
    }
}


-(void) updateUI{
    NSDictionary* addr = self.placeMark.addressDictionary;
    NSString* street = addr[@"Street"] != nil ? [NSString stringWithFormat:@"%@, ", addr[@"Street"]] : @"";
    NSString* subLocality = addr[@"SubLocality"] != nil ? [NSString stringWithFormat:@"%@, ", addr[@"SubLocality"]] : @"";
    NSString* state = addr[@"State"] != nil ? [NSString stringWithFormat:@"%@, ", addr[@"State"]] : @"";

    NSString* postCode = addr[@"ZIP"] != nil ? [NSString stringWithFormat:@"%@, ", addr[@"ZIP"]] : @"";
    
    NSString* country = addr[@"Country"] != nil ? [NSString stringWithFormat:@"%@", addr[@"Country"]] : @"";

    self.placeAddress.text = [NSString stringWithFormat:@"%@%@%@%@%@", street,subLocality, state, postCode,country];
    self.placeMarkName.text = self.placeMark.name;
}

@end
