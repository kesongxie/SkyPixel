//
//  VideoStream.m
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "VideoStream.h"

@interface VideoStream()

@end

@implementation VideoStream

- (id)init: (NSString*)title broadcastUser: (User*)user videoStreamUrl: (NSString*)url streamLocation: (CLLocation*) location{
    self = [super init];
    if(self){
        self.title = title;
        self.user = user;
        self.url = url;
        self.location = location;
    }
    return self;
}

@end
