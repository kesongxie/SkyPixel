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

- (id)init: (NSString*)fullname emailAddress: (NSString*)email avatorUrl: (NSURL*)url{
    self = [super init];
    if(self){
        self.fullname = fullname;
        self.email = email;
        self.avatorUrl = url;
        
    }
    return self;
}
@end
