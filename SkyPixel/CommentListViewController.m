//
//  CommnentListTableViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/19/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "CommentListViewController.h"
#import "CommentTableViewCell.h"
#import "AppDelegate.h"
#import "User.h"
#import "Comment.h"
#import "CKReference+Comparison.h"

@interface CommentListViewController()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *pinFooterView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (strong, nonatomic) NSArray<CKReference*> *commentReferenceList;
@property (strong, nonatomic) UIBarButtonItem *backBtn;
@property (strong, nonatomic) NSMutableArray<Comment*> *commentList;
@property (nonatomic) BOOL isSendingComment;

//update the user interface
-(void)updateUI;

//update the UI after comment is tapped
-(void)resetUIAfterCommentBtnTapped;

//show the header view
-(void)showHeaderView;

//hide the header view
-(void)hideHeaderView;

//send comment
-(void)sendComment;

//action when back button is tapped, this will segue back to the previous ViewController
-(void)backBtnTapped:(UIBarButtonItem*)backBtn;

//keyboard events
-(void)keyboardDidShow:(NSNotification*)notification;
-(void)keyboardWillHide:(NSNotification*)notification;

//control event when the user changed the text of the comment text field
-(void)textFieldValueChange;

@end

@implementation CommentListViewController

- (IBAction)commentBtnTapped:(id)sender {
    [self sendComment];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self updateUI];
    //TableView set up
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    //keyboard events
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    //textfield
    self.commentTextField.delegate = self;
    [self.commentTextField addTarget:self action:@selector(textFieldValueChange) forControlEvents:UIControlEventEditingChanged];

    self.commentList = [[NSMutableArray alloc]init];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if(!self.isSendingComment){
        if(self.commentReferenceList.count == 0){
            //no one favored yet
            [self showHeaderView];
        }else{
            [self hideHeaderView];
        }
    }
}


-(void)setVideoStream:(VideoStream *)videoStream{
    _videoStream = videoStream;
    _commentReferenceList = self.videoStream.commentReferenceList;
    [self.activitityIndicatorView startAnimating];
    self.commentList = [[NSMutableArray alloc]init];
    [Comment fetchCommentForVideoStreamReference:self.videoStream.reference completionHandler:^(NSArray<Comment *> *comments, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error == nil){
                self.commentList = [NSMutableArray arrayWithArray:comments];
                [self.activitityIndicatorView stopAnimating];
                [self.tableView reloadData];
            }else{
                NSLog(@"error is %@", error);
            }
        });
    }];
}



//MARK: - Update UI
-(void)updateUI{
    self.navigationItem.title = NSLocalizedString(@"COMMENTS", @"title");
    UIImage *backBtnImage = [UIImage imageNamed:@"back-icon"];
    self.backBtn = [[UIBarButtonItem alloc]initWithImage:backBtnImage style:UIBarButtonItemStylePlain target:self action:@selector(backBtnTapped:)];
    [self.backBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = self.backBtn;
    self.pinFooterView.layer.borderColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1].CGColor;
    self.pinFooterView.layer.borderWidth = 1.0;
}

-(void)resetUIAfterCommentBtnTapped{
    self.commentTextField.text = @"";
    [self.commentTextField resignFirstResponder];
    CGRect viewNewFrame = CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = viewNewFrame;
    }];
}


//MARK: - Header show and hide
-(void)showHeaderView{
    [self.activitityIndicatorView stopAnimating];
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
//Mark: - send coment
-(void)sendComment{
    self.isSendingComment = YES;
    self.navigationItem.title = NSLocalizedString( @"SENDING...", @"comment sending");
    NSString *text = self.commentTextField.text;
    if(text.length != 0){
        [self resetUIAfterCommentBtnTapped];
        [Comment sendComment:text inVideo:self.videoStream completionHandler:^(Comment *comment, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isSendingComment = NO;
                self.navigationItem.title = NSLocalizedString(@"COMMENTS", title);
                [self hideHeaderView];
                //update the datasource and insert the comment
                [self.commentList insertObject:comment atIndex:0];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
        }];
    }
    
}



//MARK: - backBtnTapped
-(void)backBtnTapped:(UIBarButtonItem*)backBtn{
    [self.navigationController popViewControllerAnimated:YES];
}

//MAKR: - Keyboard event
-(void)keyboardDidShow:(NSNotification*)notification{
    NSValue *value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect rect = value.CGRectValue;
    
    CGRect viewNewFrame = CGRectMake(0, -rect.size.height, self.view.frame.size.width,  self.view.frame.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = viewNewFrame;
    }];
}


-(void)keyboardWillHide:(NSNotification*)notification{
    CGRect viewNewFrame = CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = viewNewFrame;
    }];
}

// MARK: Comment text field UIControl event
-(void)textFieldValueChange{
    if(self.commentTextField.text.length == 0){
        self.commentBtn.alpha = 0.6;
        [self.commentBtn setEnabled:NO];
    }else{
        self.commentBtn.alpha = 1;
        [self.commentBtn setEnabled:YES];
    }
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.commentTextField resignFirstResponder];
}

//MARK: - UITableViewDelegate, UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentTableViewCell *cell = (CommentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    cell.comment = self.commentList[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    self.navigationItem.title = NSLocalizedString(@"DELETING...", @"comment deleting");
    [Comment deleteCommentInVideoStream:self.commentList[indexPath.row] inVideoStream:self.videoStream completionHandler:^(CKRecordID *recordID, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error == nil){
                [self.commentList removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                self.navigationItem.title = NSLocalizedString(@"COMMENTS", @"title");
            }
        });
    }];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    AppDelegate *deleagte = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CKReference *loggedinReference = deleagte.loggedInUser.reference;
    CKReference *commentOwnerReference = [[CKReference alloc]initWithRecord:self.commentList[indexPath.row].userRecord action:CKReferenceActionNone];
    if([loggedinReference isEqual:self.videoStream.userReference] || [loggedinReference isEqual:commentOwnerReference]){
        return YES;
    }else{
        return NO;
    }
}


//MARK: - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.textAlignment = NSTextAlignmentLeft;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendComment];
    return YES;
}
@end
