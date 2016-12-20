//
//  User.m
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "User.h"

@interface User()

@end

@implementation User

- (id)initWithRecord: (CKRecord*) record{
    self = [super init];
    if(self){
        self.record = record;
    }
    return self;
}

-(NSString*) fullname{
    return self.record[@"fullname"];
}

-(NSString*) email{
    return self.record[@"email"];
}

-(NSURL*) avatorUrl{
    return ((CKAsset*)self.record[@"avator"]).fileURL;
}

@end
