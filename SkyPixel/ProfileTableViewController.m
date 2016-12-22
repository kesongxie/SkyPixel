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



static NSString* const NavigationBarTitleFontName = @"Avenir-Heavy";
static CGFloat const NavigationBarTitleFontSize = 17;

@interface ProfileTableViewController()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (strong, nonatomic) UIBarButtonItem* backBtn;

@property (strong, nonatomic) NSMutableArray<VideoStream*>* videoStreamList;


-(void)updateUI;
-(void)backBtnTapped:(UIBarButtonItem*)backBtn;

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

    if(self.user != nil){
        self.avatorImageView.image = self.user.thumbImage;
        self.fullnameLabel.text = self.user.fullname;
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.avatorImageView.layer.cornerRadius = self.avatorImageView.frame.size.width / 2;
    self.avatorImageView.clipsToBounds = YES;
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
