//
//  PhotoAnnotation.h
//  SkyPixel
//
//  Created by Xie kesong on 12/9/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PhotoAnnotation : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (strong, nonatomic) NSString* thumbnailUrl;

- (id) initWithThumbnailUrl:(CLLocationCoordinate2D)coordinate url: (NSString*) thumbnailUrl;

@end
