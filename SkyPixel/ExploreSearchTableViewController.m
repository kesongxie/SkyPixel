//
//  ExploreSearchTableViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/15/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "ExploreSearchTableViewController.h"

@interface ExploreSearchTableViewController()

@property (strong, nonatomic) UISearchController* searchController;

@property (nonatomic) BOOL viewShouldExpand;

@end

@implementation ExploreSearchTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    
    self.definesPresentationContext = YES;
    
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.barTintColor = [UIColor blackColor];
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    self.navigationItem.titleView = self.searchController.searchBar;

}


-(void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (!self.viewShouldExpand){
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 0.85 * [[UIScreen mainScreen] bounds].size.width, self.view.frame.size.height);

    }
}





-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ExploreSearchCell"];
    return cell;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
   // self.viewShouldExpand = YES;
//    NSNotification* mainViewShouldDisappear = [[NSNotification alloc]initWithName:@"mainViewShouldDisappear" object:self userInfo:nil];
//    [[NSNotificationCenter defaultCenter] postNotification:mainViewShouldDisappear];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, [[UIScreen mainScreen] bounds].size.width, self.view.frame.size.height);
//
//    }];
    return YES;
}



@end
