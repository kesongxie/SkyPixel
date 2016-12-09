//
//  Photo+Annotation.m
//  SkyPixel
//
//  Created by Xie kesong on 12/9/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "Photo+Annotation.h"

@implementation Photo (Annotation)
-(CLLocationCoordinate2D) coordinate{
    return CLLocationCoordinate2DMake(self.longitude, self.latitude);
}
@end
