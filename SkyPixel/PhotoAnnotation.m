//
//  PhotoAnnotation.m
//  SkyPixel
//
//  Created by Xie kesong on 12/9/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "PhotoAnnotation.h"

@interface PhotoAnnotation() <MKAnnotation>

@end

@implementation PhotoAnnotation

- (id) initWithThumbnailUrl:(CLLocationCoordinate2D)coordinate url: (NSString*) thumbnailUrl{
    self = [super init];
    if(self){
        self.coordinate = coordinate;
        self.thumbnailUrl = thumbnailUrl;
    }
    return self;
}

@end
