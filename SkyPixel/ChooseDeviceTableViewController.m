//
//  ChooseDeviceTableViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/28/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "ChooseDeviceViewController.h"
#import "ChooseDeviceTableViewCell.h"


static NSString* const reuseIden = @"ChooseDeviceCell";

@interface ChooseDeviceViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSArray<ShotDevice*>* shotDevices;

//this method calls backBtnTapped without a parameter
-(IBAction)backBtnTapped:(UIBarButtonItem *)sender;

-(void)backBtnTapped;

@end

@implementation ChooseDeviceViewController

-(IBAction)backBtnTapped:(UIBarButtonItem *)sender {
    [self backBtnTapped];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    //tableView set up
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.activityIndicator startAnimating];
    [ShotDevice fetchAvailabeDevices:^(NSArray<ShotDevice *> *results, NSError *error) {
        if(error == nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.shotDevices = results;
                [self.activityIndicator stopAnimating];
                [self.tableView reloadData];
            });
        }
    }];
}

-(void)backBtnTapped{
    ShotDevice* shotDevice = nil;
    NSIndexPath* selectedIndexPath = self.tableView.indexPathForSelectedRow;
    NSDictionary* userInfoDict = nil;
    if(selectedIndexPath != nil){
        shotDevice = self.shotDevices[selectedIndexPath.row];
        userInfoDict = @{SelectedShotDevicesNotificationUserInfoKey : shotDevice};
    }
    NSNotification* notification = [[NSNotification alloc]initWithName:FinishedPickingShotDeviceNotificationName object:self userInfo:userInfoDict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    });
}


//MARK: TableViewDelegate and TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (self.shotDevices == nil) ? 0 : self.shotDevices.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL isSelected = ([tableView cellForRowAtIndexPath:indexPath].accessoryType ==  UITableViewCellAccessoryCheckmark);
    if(isSelected){
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        //dismiss
        [self backBtnTapped];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChooseDeviceTableViewCell* cell = (ChooseDeviceTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIden forIndexPath:indexPath];
    if(cell){
        cell.shotDevice = self.shotDevices[indexPath.row];
        if([cell.shotDevice isEqual:self.preSelectedShotDevice]){
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

@end
