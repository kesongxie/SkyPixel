//
//  User.h
//  SkyPixel
//
//  Created by Xie kesong on 12/10/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

@interface User : NSObject

@property (strong, nonatomic) CKRecord* record;
//compute from the record class
@property (strong, readonly, nonatomic) NSString* fullname;
@property (strong, readonly, nonatomic) NSString* email;
@property (strong, readonly, nonatomic) NSURL* avatorUrl;

- (id)initWithRecord: (CKRecord*) record;

@end
