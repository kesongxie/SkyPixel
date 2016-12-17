//
//  ExploreSearchViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/15/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "ExploreSearchViewController.h"

@interface ExploreSearchViewController()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end

@implementation ExploreSearchViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    
    self.scrollView.alwaysBounceVertical = YES;
    self.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationBar.translucent = NO;
}

-(void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 0.85 * [[UIScreen mainScreen] bounds].size.width, self.view.frame.size.height);
    
}

@end
