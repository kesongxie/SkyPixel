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
#import "ShotDetailViewController.h"
#import "ContainerViewController.h"
#import "LocationSearchTableViewController.h"
#import "Utility.h"


static double const LocationDegree = 0.05;
static CGFloat const searchRadius = 10000; //load video within 10 km from the locationCenter
static CGFloat const CalloutViewHeight = 50;
static NSString* const MapViewReuseIdentifier = @"AnnotationViweIden";
static NSString* const ShowCastingSegueIdentifier = @"ShowCasting";

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

- (void) fetchMediaForMap;

@end

@implementation SkyCastViewController

- (IBAction)searchIconTapped:(UIBarButtonItem *)sender {
    if([self.parentViewController.parentViewController isKindOfClass:[ContainerViewController class]]){
        ContainerViewController* containerVC = (ContainerViewController*)self.parentViewController.parentViewController;
        if([containerVC.locationSearchNavigationController.viewControllers.firstObject isKindOfClass:[LocationSearchTableViewController class]]){
            LocationSearchTableViewController* locationSearchTVC = (LocationSearchTableViewController*)containerVC.locationSearchNavigationController.viewControllers.firstObject;
            locationSearchTVC.targetForReceivingLocationSelection = self;
            [containerVC bringExploreViewToFront];
            NSNotification* notification = [[NSNotification alloc]initWithName:SearchBarShouldBecomeActiveNotificationName object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
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
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self.locationManager startUpdatingLocation];
    }   
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(locationDidSelected:) name:LocationSelectedNotificationName object:nil];
}



-(void) locationDidSelected:(NSNotification*)notification{
    if(notification.object != self){
        return;
    }
    CLLocation* location = (CLLocation*)notification.userInfo[LocationSelectedLocationInfoKey];
    if(location != nil){
        //update
        dispatch_async(dispatch_get_main_queue(), ^{
            MKPointAnnotation* spotAnnotation = [[MKPointAnnotation alloc] init];
            [spotAnnotation setCoordinate:location.coordinate];
            NSString* title = (NSString*)notification.userInfo[LocationSelectedTitleKey];
            if(title != nil){
                spotAnnotation.title = title;
                NSString* subTitle = (NSString*)notification.userInfo[LocationSelectedSubTitleKey];
                if(subTitle != nil){
                    spotAnnotation.subtitle = subTitle;
                }
            }
            self.locationCenter = location;
            [self.mapView addAnnotation:spotAnnotation];
            MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(LocationDegree, LocationDegree));
            [self.mapView setRegion:region];
            //re-fetch media content for the new location
            [self fetchMediaForMap];
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


- (void) fetchMediaForMap {
    if(self.isFetchingRecord){
        return;
    }
    self.navigationItem.title = NSLocalizedString(@"SEARCHING...", @"searching status");;
    self.isFetchingRecord = YES;
    self.videoStreamAnnotations = [[NSMutableArray alloc]init];
    [VideoStream fetchLive:self.locationCenter withRadius:searchRadius completionHandler:^(NSMutableArray<VideoStream *> *videoStreams, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for(VideoStream* videoStream in videoStreams){
                [self.videoStreamAnnotations insertObject:videoStream atIndex:0];
                [self.mapView addAnnotations: self.videoStreamAnnotations];
            }
            self.navigationItem.title =  NSLocalizedString(@"SKYCAST", @"title for map");
            self.isFetchingRecord = NO;
        });
    }];
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
        [self fetchMediaForMap];
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
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShotDetailViewController* castVC = (ShotDetailViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ShotDetailViewController"];
    VideoStream* videoStream = (VideoStream*)view.annotation;
    if(castVC){
        castVC.videoStream = videoStream;
        [self.navigationController pushViewController:castVC animated:YES];
    }
    
}

@end

