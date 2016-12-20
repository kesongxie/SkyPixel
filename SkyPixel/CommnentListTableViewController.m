//
//  CommnentListTableViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/19/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "CommentListTableViewController.h"
#import "CommentTableViewCell.h"
#import "User.h"
#import "Comment.h"

@interface CommentListTableViewController()

@property (strong, nonatomic) UIBarButtonItem* backBtn;

@property (strong, nonatomic) NSMutableArray<Comment*>* commentList;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@end


@implementation CommentListTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"FAVORS";
    UIImage* backBtnImage = [UIImage imageNamed:@"back-icon"];
    self.backBtn = [[UIBarButtonItem alloc]initWithImage:backBtnImage style:UIBarButtonItemStylePlain target:self action:@selector(backBtnTapped:)];
    [self.backBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = self.backBtn;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //reload data will trigger viewDidLayoutSubviews
    if(self.commentReferenceList.count == 0){
        //no one favored yet
        [self showHeaderView];
    }else{
        [self hideHeaderView];
    }
}

-(void)showHeaderView{
    self.headerView.hidden = NO;
    CGSize size = self.view.frame.size;
    CGFloat headerViewWidth = size.width;
    CGFloat headerViewHeight = size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    self.headerView.frame = CGRectMake(0, 0, headerViewWidth, headerViewHeight);
    [self.tableView bringSubviewToFront:self.headerView];
}

-(void)hideHeaderView{
    self.headerView.hidden = YES;
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
}

-(void)setCommentReferenceList:(NSArray<CKReference *> *)commentReferenceList{
    _commentReferenceList = commentReferenceList;
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    self.commentList = [[NSMutableArray alloc]init];
    __block NSInteger fetchCommentCounter = 0;
    for(CKReference* reference in self.commentReferenceList){
        CKRecordID* recordID = reference.recordID;
        [db fetchRecordWithID:recordID completionHandler:^(CKRecord * _Nullable commentRecord, NSError * _Nullable error) {
            CKReference* userReference = commentRecord[@"user"];
            CKRecordID* userRecordId = userReference.recordID;
            [db fetchRecordWithID:userRecordId completionHandler:^(CKRecord * _Nullable userRecord, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(error == nil){
                        Comment* comment = [[Comment alloc]initWithRecord:commentRecord WithUserRecord:userRecord];
                        [self.commentList addObject:comment];
                    }else{
                        NSLog(@"failed to fetch record %@", error.localizedDescription);
                    }
                    fetchCommentCounter += 1;
                    if(fetchCommentCounter == self.commentReferenceList.count){
                        //done with fetching
                        [self.tableView reloadData];
                    }
                });
                
            }];
        }];
    }
    
    
}

-(void)backBtnTapped:(UIBarButtonItem*)backBtn{
    [self.navigationController popViewControllerAnimated:YES];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentTableViewCell* cell = (CommentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    if(cell != nil){
//        cell.user = self.userList[indexPath.row];
    }
    return cell;
}
@end
