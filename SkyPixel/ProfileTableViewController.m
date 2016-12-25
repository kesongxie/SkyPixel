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


//constant
static NSString* MainStoryboardName = @"Main";
static NSString* CastingViewControllerIdentifier = @"CastingViewController";
static NSString* const NavigationBarTitleFontName = @"Avenir-Heavy";
static CGFloat const NavigationBarTitleFontSize = 17;

@interface ProfileTableViewController()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileActionBtn;
@property (strong, nonatomic) UIBarButtonItem* backBtn;
@property (strong, nonatomic) NSMutableArray<VideoStream*>* videoStreamList;


-(void)updateUI;
-(void)backBtnTapped:(UIBarButtonItem*)backBtn;
//present view controller for cell
-(void)presentFavorListViewController:(NSNotification*)notification;
-(void)presentCommentListViewController:(NSNotification*)notification;

@end

@implementation ProfileTableViewController


- (IBAction)backBtnTapped:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"backFromProfileTableViewController" sender:self];
}


-(void)viewDidLoad{
    [super viewDidLoad];
    //TableView set up
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.navigationController.navigationBar setBarTintColor: [UIColor blackColor]];
    UIFont* titleFont = [UIFont fontWithName: NavigationBarTitleFontName size: NavigationBarTitleFontSize];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: titleFont,    NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentFavorListViewController:) name:PresentFavorListNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCommentListViewController:) name:PresentCommentListNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCastingViewController:) name:PresentVideoDetailNotificationName object:nil];
    
    if(self.user != nil){
        self.avatorImageView.image = self.user.thumbImage;
        self.fullnameLabel.text = self.user.fullname;
        self.bioLabel.text = self.user.bio;
        self.postCountLabel.text = [NSString stringWithFormat:@"%i", self.user.videoStreamRecord.count];
    }
    
    self.profileActionBtn.layer.cornerRadius = 6.0;
    self.profileActionBtn.layer.borderColor = [UIColor colorWithRed:11/255.0 green:37/255.0 blue:84/255.0 alpha:1].CGColor;
    self.profileActionBtn.layer.borderWidth = 1.0;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.avatorImageView.layer.cornerRadius = self.avatorImageView.frame.size.width / 2;
    self.avatorImageView.clipsToBounds = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}


-(void)setUser:(User *)user{
    [self updateUI];
    _user = user;
    self.videoStreamList = [[NSMutableArray alloc]init];
    for(CKRecord* record in self.user.videoStreamRecord){
        VideoStream* videoStream = [[VideoStream alloc]initWithCKRecord:record];
        videoStream.user = self.user;
        [self.videoStreamList insertObject:videoStream atIndex:0];
    }
    [self.tableView reloadData];
}

-(void)updateUI{
    UIImage* backBtnImage = [UIImage imageNamed:@"back-icon"];
    self.backBtn = [[UIBarButtonItem alloc]initWithImage:backBtnImage style:UIBarButtonItemStylePlain target:self action:@selector(backBtnTapped:)];
    [self.backBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = self.backBtn;
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
    return self.videoStreamList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProfileTableViewCell* cell = (ProfileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
    cell.videoStream = self.videoStreamList[indexPath.row];
    return cell;
}


@end
