//
//  Comment.m
//  SkyPixel
//
//  Created by Xie kesong on 12/19/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "Comment.h"

@interface Comment()

@end

@implementation Comment

- (id)initWithRecord: (CKRecord*) record WithUserRecord: (CKRecord*) userRecord{
    self = [super init];
    if(self){
        self.record = record;
        self.userRecord = userRecord;
    }
    return self;
}

/*
 @property (strong, readonly, nonatomic) NSString* createdDate;
 @property (strong, readonly, nonatomic) NSString* text;
 @property (strong, readonly, nonatomic) User* user;
 */

-(NSString*) createdDate{
    return @"3w";
}
-(NSString*) text{
    return self.record[@"text"];
}

-(NSString*)fullname{
    return self.userRecord[@"fullname"];
}

-(NSURL*)avatorURL{
    return ((CKAsset*)self.userRecord[@"avator"]).fileURL;

}

@end
