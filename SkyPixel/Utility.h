//
//  PrettyDateFormatter.h
//  SkyPixel
//
//  Created by Xie kesong on 12/20/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Utility : NSObject


/**
 Covert date to Ago format
*/
+(NSString*)agoFormatterFromDate: (NSDate*) date;

/**
 Generate a thmbnail image for a video asset
 */
+(UIImage *)generateThumbImage : (NSURL *)url;

@end
