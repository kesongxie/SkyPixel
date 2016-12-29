//
//  EditPostMediaPickerController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/27/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <Photos/Photos.h>
#import "EditPostMediaPickerController.h"
#import "MediaPickerCollectionViewCell.h"
#import "EditPostAddDetailViewController.h"

static CGFloat const Space = 12;
static CGFloat const cacheThumbnailSizeWidth = 120;


@interface EditPostMediaPickerController ()<UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (strong, nonatomic) NSMutableArray<PHAsset*>* assets;
@property (strong, nonatomic) PHCachingImageManager* cacheManager;
@property (strong, nonatomic) MediaPickerCollectionViewCell* selectedVideo;
@property (nonatomic) BOOL preferStatusBarHidden;

@end

@implementation EditPostMediaPickerController

-(IBAction)backBtnTapped:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //slide up the status bar
        self.preferStatusBarHidden = YES;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }];
}


-(BOOL)prefersStatusBarHidden{
    return self.preferStatusBarHidden;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}



-(void) viewDidLoad{
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self updateBtnUI];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch(status){
            case PHAuthorizationStatusAuthorized :
                [self fetchAfterAuthorized];
                break;
            default:
                break;
        }
    }];
}




// Next button UI and control
-(void)updateBtnUI{
    self.nextBtn.layer.borderColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1].CGColor;
    self.nextBtn.layer.borderWidth = 1.0;
    [self setNextBtnDisabled];
}

-(void)setNextBtnEnabled{
    self.nextBtn.alpha = 1;
    [self.nextBtn setEnabled:YES];
}

-(void)setNextBtnDisabled{
    self.nextBtn.alpha = 0.5;
    [self.nextBtn setEnabled:NO];
}

-(void)updateNextBtnUIAfterCellSelection{
    if(self.selectedVideo != nil){
        [self setNextBtnEnabled];
    }else{
        [self setNextBtnDisabled];
    }
}

-(void)fetchAfterAuthorized{
    PHFetchResult<PHAsset *>* results = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil];
    self.assets = [[NSMutableArray alloc]init];
    [results enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.assets insertObject:asset atIndex:0];
    }];
    self.cacheManager = [[PHCachingImageManager alloc]init];
    CGSize cacheThumbnailSize = CGSizeMake(cacheThumbnailSizeWidth, cacheThumbnailSizeWidth);
    [self.cacheManager startCachingImagesForAssets:self.assets targetSize: cacheThumbnailSize contentMode:PHImageContentModeAspectFill options:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
          [self.collectionView reloadData];
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    EditPostAddDetailViewController* detailVC = (EditPostAddDetailViewController*)segue.destinationViewController;
    if(detailVC){
        detailVC.asset = self.selectedVideo.asset;
        detailVC.thumbnailImage = self.selectedVideo.image;
    }
}



//MARK: - CollectionViewDelegate, CollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return (self.assets == nil) ? 0 : self.assets.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MediaPickerCollectionViewCell* cell = (MediaPickerCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MediaPickerCell" forIndexPath:indexPath];
    
    CGSize cacheThumbnailSize = CGSizeMake(cacheThumbnailSizeWidth, cacheThumbnailSizeWidth);
    [self.cacheManager requestImageForAsset:self.assets[indexPath.row] targetSize:cacheThumbnailSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        cell.image = image;
        cell.asset = self.assets[indexPath.row];
    }];
    
    cell.layer.cornerRadius = 6.0;
    cell.layer.borderColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1].CGColor;
    cell.layer.borderWidth = 1.0;
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
     MediaPickerCollectionViewCell* selectedCell = (MediaPickerCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if(self.selectedVideo != nil){
        ////Clear the selected view from the previous selected cell
        [self.selectedVideo.selectedContainerAccessoryView setHidden:YES];
    }
    if(self.selectedVideo == selectedCell){
        self.selectedVideo = nil;
    }else{
        self.selectedVideo = selectedCell;
        [self.selectedVideo.selectedContainerAccessoryView setHidden:NO];
    }
    [self updateNextBtnUIAfterCellSelection];
}


//MARK: - CollectionViewFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (self.view.frame.size.width - 3 * Space) / 2;
    return CGSizeMake(width, width);

}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return Space;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(Space, Space, Space, Space);
}

@end






