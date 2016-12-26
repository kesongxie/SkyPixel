//
//  ProfileTableViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/21/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "ProfileTableViewController.h"
#import <Foundation/Foundation.h>
#import "VideoStream.h"
#import "ProfileTableViewCell.h"
#import "CastingViewController.h"
#import "UIImageView+ProfileAvator.h"



//constant
static NSString* const MainStoryboardName = @"Main";
static NSString* const CastingViewControllerIdentifier = @"CastingViewController";


@interface ProfileTableViewController()

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverHeightConstriant;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic) CGFloat orginCoverHeight;
@property (nonatomic) CGPoint backBtnOrigin;


@property (strong, nonatomic) NSMutableArray<VideoStream*>* videoStreamList;
//@property (strong, nonatomic) UIBarButtonItem* backBtn;


@property (nonatomic) BOOL preferStatusBarHidden;

//present view controller for cell
-(void)presentFavorListViewController:(NSNotification*)notification;
-(void)presentCommentListViewController:(NSNotification*)notification;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation ProfileTableViewController

- (IBAction)backBtnTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    //TableView set up
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentFavorListViewController:) name:PresentFavorListNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCommentListViewController:) name:PresentCommentListNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCastingViewController:) name:PresentVideoDetailNotificationName object:nil];
    
    if(self.user != nil){
        [self.avatorImageView becomeAvatorProifle:self.user.thumbImage];
        self.avatorImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.avatorImageView.layer.borderWidth = 3.0;
        self.fullnameLabel.text = self.user.fullname;
        self.coverImageView.image = self.user.coverThumbImage;
        self.bioLabel.text = self.user.bio;
        self.followBtn.layer.cornerRadius = 3.0;
    }
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self adjustCoverView];
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.alpha = 0;
}




-(void)adjustCoverView{
    CGSize coverImageSize = self.coverImageView.image.size;
    self.coverHeightConstriant.constant = self.view.frame.size.width * coverImageSize.height /  coverImageSize.width;
    self.orginCoverHeight = self.coverHeightConstriant.constant;
}

//MARK: UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y < 0){
        CGRect coverRect = CGRectMake(0, scrollView.contentOffset.y,self.coverImageView.frame.size.width, self.orginCoverHeight + (-scrollView.contentOffset.y));
        self.coverImageView.frame = coverRect;
        CGRect backBtnRect = CGRectMake(self.backBtnOrigin.x, self.backBtnOrigin.y + scrollView.contentOffset.y, self.backBtn.frame.size.width, self.backBtn.frame.size.height);
        self.backBtn.frame = backBtnRect;
        
        
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.preferStatusBarHidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    self.backBtnOrigin = self.backBtn.frame.origin;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(BOOL)prefersStatusBarHidden{
    return self.preferStatusBarHidden;
}



-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(void)setUser:(User *)user{
    _user = user;
    self.videoStreamList = [[NSMutableArray alloc]init];
    for(CKRecord* record in self.user.videoStreamRecord){
        VideoStream* videoStream = [[VideoStream alloc]initWithCKRecord:record];
        videoStream.user = self.user;
        [self.videoStreamList insertObject:videoStream atIndex:0];
    }
    [self.tableView reloadData];
}

-(void)presentFavorListViewController:(NSNotification*)notification {
    FavorUserListViewController* favorListVC = (FavorUserListViewController*)notification.userInfo[FavorUserListVCKey];
    if(favorListVC != nil){
        [self.navigationController pushViewController:favorListVC animated:YES];
    }
}

-(void)presentCommentListViewController:(NSNotification*)notification {
    CommentListViewController* commentListVC = (CommentListViewController*)notification.userInfo[CommentUserListVCKey];
    if(commentListVC != nil){
        [self.navigationController pushViewController:commentListVC animated:YES];
    }
}

-(void)presentCastingViewController:(NSNotification*)notification {
    VideoStream* videoStream = (VideoStream*)notification.userInfo[VideoDetailKey];
    if(videoStream != nil){
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:MainStoryboardName bundle:nil];
        CastingViewController* castingVC = (CastingViewController*)[storyboard instantiateViewControllerWithIdentifier:CastingViewControllerIdentifier];
        castingVC.videoStream = videoStream;
        [self.navigationController pushViewController:castingVC animated:YES];
    }
}

//MARK: - TableViewDelegate, TableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0; //self.videoStreamList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProfileTableViewCell* cell = (ProfileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
    cell.videoStream = self.videoStreamList[indexPath.row];
    return cell;
}

@end
