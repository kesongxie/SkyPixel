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

- (id)init: (NSString*)title broadcastUser: (User*)user videoStreamUrl: (NSURL*)url streamLocation: (CLLocation*) location isLive: (NSInteger)live favorUserList: (NSArray<CKReference*>*) favorUserList{
    self = [super init];
    if(self){
        self.title = title;
        self.user = user;
        self.url = url;
        self.location = location;
        self.live = live;
        self.favorUserList = favorUserList;
    }
    return self;
}

- (BOOL) isLive{
    return self.live == 1;
}

@end
