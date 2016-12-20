//
//  CommnentTableViewCell.m
//  SkyPixel
//
//  Created by Xie kesong on 12/19/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "CommentTableViewCell.h"

@interface CommentTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;

@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;





@end

@implementation CommentTableViewCell

-(void)setComment:(Comment*)comment{
    NSLog(@"set comment");
    _comment = comment;
    //update UI
    self.fullnameLabel.text = self.comment.fullname;
    NSData* imageData = [[NSData alloc]initWithContentsOfURL:self.comment.avatorURL];
    UIImage* avator = [[UIImage alloc]initWithData:imageData];
    self.avatorImageView.image = avator;
    self.avatorImageView.layer.cornerRadius = self.avatorImageView.frame.size.width / 2;
    self.avatorImageView.clipsToBounds = YES;
    
    
    
}


@end

