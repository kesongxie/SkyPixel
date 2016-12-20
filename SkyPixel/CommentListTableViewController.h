//
//  CommnentListTableViewController.h
//  SkyPixel
//
//  Created by Xie kesong on 12/19/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import <Foundation/Foundation.h>

@interface CommentListTableViewController: UITableViewController

@property (strong, nonatomic) NSArray<CKReference*>* commentReferenceList;

@end
