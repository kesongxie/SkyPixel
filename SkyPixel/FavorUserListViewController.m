//
//  FavorUserListTableViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/19/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "FavorUserListViewController.h"
#import "User.h"
#import "FavorTableViewCell.h"

@interface FavorUserListViewController()

@property (strong, nonatomic) UIBarButtonItem* backBtn;

@property (strong, nonatomic) NSMutableArray<User*>* userList;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end


@implementation FavorUserListViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    //TableView set up
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.title = @"FAVORS";
    UIImage* backBtnImage = [UIImage imageNamed:@"back-icon"];
    self.backBtn = [[UIBarButtonItem alloc]initWithImage:backBtnImage style:UIBarButtonItemStylePlain target:self action:@selector(backBtnTapped:)];
    [self.backBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = self.backBtn;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //reload data will trigger viewDidLayoutSubviews
    if(self.favorUserList.count == 0){
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


-(void)setFavorUserList:(NSArray<CKReference *> *)favorUserList{
    _favorUserList = favorUserList;
    [self.activityIndicatorView startAnimating];
    CKDatabase* db = [CKContainer defaultContainer].publicCloudDatabase;
    self.userList = [[NSMutableArray alloc]init];
    __block NSInteger fetchUserCounter = 0;
    for(CKReference* reference in self.favorUserList){
        CKRecordID* recordID = reference.recordID;
        [db fetchRecordWithID:recordID completionHandler:^(CKRecord * _Nullable userRecord, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(error == nil){
                    User* user = [[User alloc]initWithRecord:userRecord];
                    [self.userList addObject:user];
                }else{
                    NSLog(@"failed to fetch record %@", error.localizedDescription);
                }
                
                fetchUserCounter += 1;
                if(fetchUserCounter == self.favorUserList.count){
                    //done with fetching
                    [self.activityIndicatorView stopAnimating];
                    [self.tableView reloadData];
                }
            });
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
    return self.userList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FavorTableViewCell* cell = (FavorTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FavorCell" forIndexPath:indexPath];
    if(cell != nil){
        cell.user = self.userList[indexPath.row];
    }
    return cell;
}
@end
