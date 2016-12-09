//
//  SkyCastViewController.m
//  SkyPixel
//
//  Created by Xie kesong on 12/4/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//

#import "SkyCastViewController.h"
#import "AppDelegate.h"
#import "SkyPixel-Swift.h"
#import "Photo+Annotation.h"
#import <CoreLocation/CoreLocation.h>

//static CLLocationDegrees const LocationDegree = 0.01;
static NSString* const NavigationBarTitleFontName = @"Avenir-Heavy";
static CGFloat const NavigationBarTitleFontSize = 17;
//static CLLocationDistance const LocationFilter = 50; //send location update event: movment over 50 meters
static NSString* const MapViewReuseIdentifier = @"AnnotationViweIden";

@interface SkyCastViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSArray* photos;


@end

//latitude = 32.888322
//longitude = -117.241385

@implementation SkyCastViewController

- (void) viewDidLoad{
    [super viewDidLoad];
    [self updateUI];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.mapView.delegate = self;

    //listen to document ready notificationfor core data
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(documentInit:) name:DocumentReadyNotificationName object: nil];
    
    [self.locationManager requestWhenInUseAuthorization];
    if( [CLLocationManager authorizationStatus]== kCLAuthorizationStatusAuthorizedWhenInUse){
        //Start updating my location
        //self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
      //  self.locationManager.distanceFilter = LocationFilter;
//        self.mapView.showsUserLocation = YES;
        //[self.locationManager startUpdatingLocation];
    }
}

// document ready observer
- (void) documentInit: (NSNotification*) notification{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* context = appDelegate.document.managedObjectContext;
    NSError* error;
    //fetch objects
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.fetchBatchSize = 10;
    request.fetchLimit = 100;
    NSString* nameAttr = @"name";
    NSString* nameValue = @"Kesong Xie";
    request.predicate = [NSPredicate predicateWithFormat:@"%K like %@", nameAttr, nameValue];
    NSArray* users = [context executeFetchRequest:request error: &error];
    if(error != nil){
        NSLog(@"%@", error.localizedDescription);
    }else{
        if([users count] > 0){
            NSLog(@"----------------before - %@-----------------", self.mapView.annotations);
            for(User* user in users){
               self.photos = (NSArray<Photo<MKAnnotation>*>*)user.photo.allObjects;
//                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mapView addAnnotations:self.photos];
                    [self.mapView showAnnotations: self.photos animated:YES];
               // });
                NSLog(@"----------------after - %@-----------------", self.mapView.annotations);
            }
        }
    }
    
   
    
}


//MARK: - UPATE UI
- (void) updateUI{
    [self.navigationController.navigationBar setBarTintColor: [UIColor blackColor]];
    UIFont* titleFont = [UIFont fontWithName: NavigationBarTitleFontName size: NavigationBarTitleFontSize];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: titleFont,    NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//MARK: - CLLocationManagerDelegate
//-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
//    if([locations count] > 0){
//        CLLocation* currentLocation = locations.lastObject;
//        MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(LocationDegree, LocationDegree));
//        [self.mapView setRegion:region];
//        [self.locationManager stopUpdatingLocation];
//    }
//}


//MARK: - MKMapViewDelegate
-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    NSLog(@"vieForAnnotation called");
    
    if([annotation isKindOfClass:[ MKUserLocation class]]){
        return nil;
    }
    MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier: MapViewReuseIdentifier];
    if(!annotationView){
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MapViewReuseIdentifier];
    }else{
        annotationView.annotation = annotation;
    }
    return annotationView;
}

@end
