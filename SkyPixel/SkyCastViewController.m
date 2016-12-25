//
//  SkyCastViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/4/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CloudKit/CloudKit.h>
#import "SkyCastViewController.h"
#import "VideoStream+Annotation.h"
#import "PlayView.h"
#import "CastingViewController.h"
#import "ContainerViewController.h"
#import "Utility.h"


static double const LocationDegree = 0.05;
static NSString* const NavigationBarTitleFontName = @"Avenir-Heavy";
static CGFloat const NavigationBarTitleFontSize = 17;
static NSString* const MapViewReuseIdentifier = @"AnnotationViweIden";
static NSString* const ShowCastingSegueIdentifier = @"ShowCasting";
static NSString* const email1 = @"kesongxie@skypixel.com";
static CGFloat const searchRadius = 10000; //load video within 10 km from the locationCenter
static CGFloat const CalloutViewHeight = 50;


@interface SkyCastViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray* photos;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSMutableArray<VideoStream*>* videoStreamAnnotations;
@property (strong, nonatomic) AVAsset* asset;
@property (strong, nonatomic) AVPlayerItem* playerItem;
@property (strong, nonatomic) AVPlayer* player;
@property (strong, nonatomic) PlayerView* playerView;
@property (strong, nonatomic) NSString* payerItemContext;
@property (strong, nonatomic) UISearchController* searchController;
@property (strong, nonatomic) CLLocation* locationCenter; //the surrounding footage will be loaded
@property (nonatomic) BOOL isFetchingRecord;

- (void) fetchLive;

@end

@implementation SkyCastViewController

- (IBAction)searchIconTapped:(UIBarButtonItem *)sender {
    if([self.parentViewController.parentViewController isKindOfClass:[ContainerViewController class]]){
        ContainerViewController* containerVC = (ContainerViewController*)self.parentViewController.parentViewController;
        [containerVC bringExploreViewToFront];
        NSNotification* notification = [[NSNotification alloc]initWithName:@"SearchIconTapped" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (IBAction)dotBtnTapped:(UIBarButtonItem *)sender {
    if([self.parentViewController.parentViewController isKindOfClass: [ContainerViewController class]]){
        ContainerViewController* containerVC = (ContainerViewController*)self.parentViewController.parentViewController;
        [containerVC toggleLeftMainView];
    }
}


- (void) viewDidLoad{
    [super viewDidLoad];
    [self updateUI];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self.locationManager startUpdatingLocation];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(didPlayToEnd:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(locationDidSelected:) name:@"LocationSelected" object:nil];
}

-(void) didPlayToEnd:(NSNotification*)notification{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}


-(void) locationDidSelected:(NSNotification*)notification{
    CLLocation* location = (CLLocation*)notification.userInfo[@"location"];
    if(location != nil){
        //update
        dispatch_async(dispatch_get_main_queue(), ^{
            MKPointAnnotation* spotAnnotation = [[MKPointAnnotation alloc] init];
            [spotAnnotation setCoordinate:location.coordinate];
            NSString* title = (NSString*)notification.userInfo[@"title"];
            if(title != nil){
                spotAnnotation.title = title;
                NSString* subTitle = (NSString*)notification.userInfo[@"subTitle"];
                if(subTitle != nil){
                    spotAnnotation.subtitle = subTitle;
                }
            }
            self.locationCenter = location;
            [self.mapView addAnnotation:spotAnnotation];
            MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(LocationDegree, LocationDegree));
            [self.mapView setRegion:region];
            //fetch live
            [self fetchLive];
        });
    }else{
        NSLog(@"location is nil");
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(BOOL)hidesBottomBarWhenPushed {
    return YES;
}


- (void) fetchLive {
    if(self.isFetchingRecord){
        return;
    }
    //start loading drone flying user
    CKDatabase* publicDB = [[CKContainer defaultContainer] publicCloudDatabase];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"distanceToLocation:fromLocation:(location, %@) < %f", self.locationCenter, searchRadius];
    CKQuery* query = [[CKQuery alloc] initWithRecordType:@"videostream" predicate: predicate];
    self.navigationItem.title = NSLocalizedString(@"SEARCHING...", @"searching status");;
    self.isFetchingRecord = YES;
    [publicDB performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord*>* videoStreamRecords, NSError* error){
        if(error == nil){
            if(videoStreamRecords){
                NSLog(@"record is ready");
                self.videoStreamAnnotations = [[NSMutableArray alloc]init];
                __block NSInteger userFetchedCompletedCount = 0;
                for(CKRecord* streamRecord in videoStreamRecords){
                    VideoStream* videoStream = [[VideoStream alloc]initWithCKRecord:streamRecord];
                    [videoStream fetchUserForVideoStream:^(CKRecord *userRecord, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.videoStreamAnnotations insertObject:videoStream atIndex:0];
                            [self.mapView addAnnotations: self.videoStreamAnnotations];
                            userFetchedCompletedCount = userFetchedCompletedCount + 1;
                            if(userFetchedCompletedCount == videoStreamRecords.count){
                                //The fetching for all the users are now completed
                                self.navigationItem.title =  NSLocalizedString(@"SKYCAST", @"title for map");
                                self.isFetchingRecord = NO;
                            }
                        });
                    }];
                }
            }
        }else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}


//MARK: - UPATE UI
- (void) updateUI{
    [self.navigationController.navigationBar setBarTintColor: [UIColor blackColor]];
    UIFont* titleFont = [UIFont fontWithName: NavigationBarTitleFontName size: NavigationBarTitleFontSize];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: titleFont,    NSForegroundColorAttributeName: [UIColor whiteColor]}];
}


//MARK: - Prepare for segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self.player pause];
    if([sender isKindOfClass:[MKAnnotationView class]]){
        if([segue.identifier isEqualToString:ShowCastingSegueIdentifier]){
            if([segue.destinationViewController isKindOfClass:[CastingViewController class]]){
                CastingViewController* destinationVC = segue.destinationViewController;
                VideoStream* videoStream = ((MKAnnotationView*)sender).annotation;
                destinationVC.videoStream = videoStream;

            }
        }
    }
}

//MARK: - CLLocationManagerDelegate
-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        [manager startUpdatingLocation];
    }else{
        NSLog(@"Location not authorized");
    }
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if([locations count] > 0){
        CLLocation* currentLocation = locations.lastObject;
        self.locationCenter = currentLocation;
        MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(LocationDegree, LocationDegree));
        [self.mapView setRegion:region];
        [self fetchLive];
        [manager stopUpdatingLocation];
    }
}


//MARK: - MKMapViewDelegate
-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if([annotation isKindOfClass:[ MKUserLocation class]]){
        return nil;
    }else if([annotation isKindOfClass:[ MKPointAnnotation class]]){
        return nil;
    }
    MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier: MapViewReuseIdentifier];
    if(!annotationView){
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MapViewReuseIdentifier];
    }else{
        annotationView.annotation = annotation;
    }
    VideoStream* videoStream = (VideoStream*)annotation;
    annotationView.image = videoStream.thumbImage;
    annotationView.frame = CGRectMake(0, 0, 60, 60);
    annotationView.layer.borderColor = [[UIColor whiteColor] CGColor];
    annotationView.layer.borderWidth = 2.0;
    annotationView.canShowCallout = YES;
    if([videoStream isLive]){
        //add overlay
        UIView* overlayView = [[UIView alloc]initWithFrame:annotationView.frame];
        overlayView.backgroundColor = [UIColor blackColor];
        overlayView.alpha = 0.1;
        [annotationView addSubview:overlayView];
        //add video icon
        UIImage* liveIcon = [UIImage imageNamed:@"live-icon"];
        UIImageView* liveIconImageView = [[UIImageView alloc] initWithImage:liveIcon];
        liveIconImageView.frame = CGRectMake(36, 6, 18, 14);
        [annotationView addSubview:liveIconImageView];
    }

    return annotationView;
}

-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if([view.annotation isKindOfClass:[VideoStream class]]){
        //configure left callout accessory view
        VideoStream* videoStream = (VideoStream*)view.annotation;
        CGRect rect = CGRectMake(0, 0, CalloutViewHeight * videoStream.width / videoStream.height, CalloutViewHeight);
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:rect];
        imageView.image = videoStream.thumbImage;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        view.leftCalloutAccessoryView = imageView;

        //configure right callout accessory view and btn
        UIImage* arrowIcon = [UIImage imageNamed:@"arrow-icon"];
        UIButton* disclosureBtn = [[UIButton alloc]init];
        [disclosureBtn sizeToFit];
        [disclosureBtn setBackgroundImage:arrowIcon forState:UIControlStateNormal];
        view.rightCalloutAccessoryView = disclosureBtn;
    }
}


-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    [self performSegueWithIdentifier:ShowCastingSegueIdentifier sender: view];
}

@end

