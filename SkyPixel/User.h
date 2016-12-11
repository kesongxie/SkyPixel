//
//  User.h
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString* fullname;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSURL* avatorUrl;

- (id)init: (NSString*)fullname emailAddress: (NSString*)email avatorUrl: (NSURL*)url;


@end
