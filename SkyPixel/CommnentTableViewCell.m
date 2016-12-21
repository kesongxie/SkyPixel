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
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdDataLabel;

@end

@implementation CommentTableViewCell

-(void)setComment:(Comment*)comment{
    _comment = comment;
    //update UI
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData* imageData = [[NSData alloc]initWithContentsOfURL:self.comment.avatorURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* avator = [[UIImage alloc]initWithData:imageData];
            self.avatorImageView.image = avator;
        });
    });
    self.fullnameLabel.text = self.comment.fullname;
    self.avatorImageView.layer.cornerRadius = self.avatorImageView.frame.size.width / 2;
    self.avatorImageView.clipsToBounds = YES;
    self.commentTextLabel.text = self.comment.text;
    self.createdDataLabel.text = self.comment.createdDate;
}


@end

