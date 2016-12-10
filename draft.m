////
////  SkyCastViewController.m
////  SkyPixel
////
////  Created by Xie kesong on 12/4/16.
////  Copyright © 2016 ___KesongXie___. All rights reserved.
////
//
//#import "SkyCastViewController.h"
//#import "AppDelegate.h"
//#import "SkyPixel-Swift.h"
//#import "Photo+Annotation.h"
//#import <CoreLocation/CoreLocation.h>
//
//static CLLocationDegrees const LocationDegree = 0.01;
//static NSString* const NavigationBarTitleFontName = @"Avenir-Heavy";
//static CGFloat const NavigationBarTitleFontSize = 17;
//static CLLocationDistance const LocationFilter = 50; //send location update event: movment over 50 meters
//static NSString* const MapViewReuseIdentifier = @"AnnotationViweIden";
//
//@interface SkyCastViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
//
//@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//@property (strong, nonatomic) CLLocationManager* locationManager;
//@end
//
////latitude = 32.888322
////longitude = -117.241385
//
//@implementation SkyCastViewController
//
//- (void) viewDidLoad{
//    [super viewDidLoad];
//    [self updateUI];
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    self.mapView.delegate = self;
//    
//    //listen to document ready notificationfor core data
//    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(documentInit:) name:DocumentReadyNotificationName object: nil];
//    
//    
//    [self.locationManager requestWhenInUseAuthorization];
//    if( [CLLocationManager authorizationStatus]== kCLAuthorizationStatusAuthorizedWhenInUse){
//        //authorized
//        
//        //        CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
//        //        [geoCoder reverseGeocodeLocation:myLocation completionHandler:^(NSArray* placeMarks, NSError* error){
//        //            if([placeMarks count] > 0){
//        //                for(CLPlacemark* mark in placeMarks){
//        //                    NSLog(@"postcode %@", mark.postalCode);
//        //                    NSLog(@"name %@", mark.name);
//        //                    NSLog(@"street adddress is %@", mark.thoroughfare);
//        //                }
//        //            }
//        //        }];
//        
//        //Start updating my location
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        self.locationManager.distanceFilter = LocationFilter;
//        self.mapView.showsUserLocation = YES;
//        [self.locationManager startUpdatingLocation];
//        
//    }else{
//        NSLog(@"NOT AUTHORI");
//    }
//}
//
//// document ready observer
//- (void) documentInit: (NSNotification*) notification{
//    
//    
//    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    NSManagedObjectContext* context = appDelegate.document.managedObjectContext;
//    
//    NSError* error;
//    
//    //  set up the first user and its information
//    //auto saved
//    //insert entry to table
//    //
//    //    Photo* photo1 = [NSEntityDescription insertNewObjectForEntityForName: @"Photo" inManagedObjectContext: context];
//    //    [photo1 setLongitude: self.locationManager.location.coordinate.longitude];
//    //    [photo1 setLatitude: self.locationManager.location.coordinate.latitude];
//    //    [photo1 setTitle:@"Aerial Shots of Sedona Arizona"];
//    //    UIImage* photo1Image = [[UIImage alloc] initWithContentsOfFile:@"shot1"];
//    //    NSData* photo1ImageData = UIImagePNGRepresentation(photo1Image);
//    //    if(photo1ImageData){
//    //        [photo1 setThumbnailData: photo1ImageData];
//    //    }
//    //
//    //    Photo* photo2 = [NSEntityDescription insertNewObjectForEntityForName: @"Photo" inManagedObjectContext: context];
//    //    [photo2 setLongitude: self.locationManager.location.coordinate.longitude];
//    //    [photo2 setLatitude: self.locationManager.location.coordinate.latitude];
//    //    [photo2 setTitle:@"Beach Walking"];
//    //    UIImage* photo2Image = [[UIImage alloc] initWithContentsOfFile:@"shot2"];
//    //    NSData* photo2ImageData = UIImagePNGRepresentation(photo2Image);
//    //    if(photo2ImageData){
//    //        [photo2 setThumbnailData: photo2ImageData];
//    //    }
//    //
//    //
//    //    User* user1 = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
//    //    [user1 setName:@"Kesong Xie"];
//    //    NSMutableSet* photoSet = [[NSMutableSet alloc] init];
//    //    [photoSet addObject:photo1];
//    //    [photoSet addObject:photo2];
//    //
//    //    [user1 setPhoto: photoSet];
//    //
//    //
//    //
//    
//    
//    //  self.mapView.annotations
//    
//    //fetch objects
//    //    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
//    //    request.fetchBatchSize = 10;
//    //    request.fetchLimit = 100;
//    //    NSString* nameAttr = @"name";
//    //    NSString* nameValue = @"Kesong Xie";
//    //    request.predicate = [NSPredicate predicateWithFormat:@"%K like %@", nameAttr, nameValue];
//    //    NSArray* users = [context executeFetchRequest:request error: &error];
//    //    if(error != nil){
//    //        NSLog(@"%@", error.localizedDescription);
//    //    }else{
//    //        if([users count] > 0){
//    //           for(User* user in users){
//    //             //  [self.mapView addAnnotations: (NSArray<Photo<MKAnnotation>*>*)user.photo.allObjects];
//    //              // [self.mapView showAnnotations:(NSArray<Photo<MKAnnotation>*>*)user.photo.allObjects animated:YES];
//    //            }
//    //        }else{
//    //            NSLog(@"photo not being saved yet");
//    //        }
//    //    }
//    //
//    
//    
//    
//    //    NSFetchRequest* userDeleteRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
//    //    NSBatchDeleteRequest* userDeleteBatchRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:userDeleteRequest];
//    //    [context executeRequest:userDeleteBatchRequest error: &error];
//    //
//    
//    
//}
//
//
////MARK: - UPATE UI
//- (void) updateUI{
//    [self.navigationController.navigationBar setBarTintColor: [UIColor blackColor]];
//    UIFont* titleFont = [UIFont fontWithName: NavigationBarTitleFontName size: NavigationBarTitleFontSize];
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: titleFont,    NSForegroundColorAttributeName: [UIColor whiteColor]}];
//}
//
//- (UIStatusBarStyle) preferredStatusBarStyle{
//    return UIStatusBarStyleLightContent;
//}
//
////MARK: - CLLocationManagerDelegate
//-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
//    if([locations count] > 0){
//        CLLocation* currentLocation = locations.lastObject;
//        MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(LocationDegree, LocationDegree));
//        
//        [self.mapView setRegion:region];
//        [self.locationManager stopUpdatingLocation];
//    }
//}
//
//
////MARK: - MKMapViewDelegate
//-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
//    MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier: MapViewReuseIdentifier];
//    if(!annotationView){
//        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MapViewReuseIdentifier];
//    }
//    NSLog(@"method called");
//    NSLog(@"%@", annotation);
//    
//    annotationView.annotation = annotation;
//    return annotationView;
//}
//
//
//
//
//
//
//@end





//
//
//
//
//
//
//
//
//
////
////  SkyCastViewController.m
////  SkyPixel
////
////  Created by Xie kesong on 12/4/16.
////  Copyright © 2016 ___KesongXie___. All rights reserved.
////
//
//#import "SkyCastViewController.h"
//#import "AppDelegate.h"
//#import "SkyPixel-Swift.h"
//#import "Photo+Annotation.h"
//#import <CoreLocation/CoreLocation.h>
//
////static CLLocationDegrees const LocationDegree = 0.01;
////static CLLocationDistance const LocationFilter = 50; //send location update event: movment over 50 meters
//
//static NSString* const NavigationBarTitleFontName = @"Avenir-Heavy";
//static CGFloat const NavigationBarTitleFontSize = 17;
//static NSString* const MapViewReuseIdentifier = @"AnnotationViweIden";
//
//@interface SkyCastViewController () <MKMapViewDelegate>
//
//@property (weak, nonatomic) IBOutlet MKMapView *mapView;
////@property (strong, nonatomic) CLLocationManager* locationManager;
//@property (strong, nonatomic) NSArray* photos;
//
//@property (strong, nonatomic) UIManagedDocument* document;
//
//
//
//@end
//
//@implementation SkyCastViewController
//
//- (void) viewDidLoad{
//    [super viewDidLoad];
//    [self updateUI];
//    //self.locationManager = [[CLLocationManager alloc] init];
//    // self.locationManager.delegate = self;
//    self.mapView.delegate = self;
//    
//    //    //listen to document ready notificationfor core data
//    //    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(documentInit:) name:DocumentReadyNotificationName object: nil];
//    
//    //    [self.locationManager requestWhenInUseAuthorization];
//    //    if( [CLLocationManager authorizationStatus]== kCLAuthorizationStatusAuthorizedWhenInUse){
//    //       // Start updating my location
//    //        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    //        self.locationManager.distanceFilter = LocationFilter;
//    //        self.mapView.showsUserLocation = YES;
//    //        [self.locationManager startUpdatingLocation];
//    //    }
//}
//
//- (void) viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    
//    //    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(32.88831721994364, -117.24139452);
//    //
//    //    Photo* myAnnotation = [[Photo alloc] init];
//    //    myAnnotation.coordinate = location;
//    //    self.photos = @[myAnnotation];
//    //    [self.mapView addAnnotations:self.photos];
//    //    [self.mapView showAnnotations:self.photos animated:YES];
//    //
//    
//    
//    
//    
//    
//    
//    
//    
//    NSFileManager* fileManager = [NSFileManager defaultManager];
//    NSURL* docsDir = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
//    if(docsDir){
//        NSURL* url = [docsDir URLByAppendingPathComponent:@"storage"];
//        self.document = [[UIManagedDocument alloc] initWithFileURL: url];
//        if(self.document.documentState != UIDocumentStateNormal){
//            if([[NSFileManager defaultManager] fileExistsAtPath: url.path]){
//                //the document exists, open it
//                [self.document openWithCompletionHandler:^(BOOL success){
//                    if(success){
//                        [self documentInit];
//                    }
//                }];
//            }else{
//                //the document does not exist, create one
//                [self.document saveToURL:url forSaveOperation: UIDocumentSaveForCreating completionHandler:^(BOOL success){
//                    //post a notification that document is ready
//                    if(success){
//                        NSLog(@"saveToURL succeed");
//                    }else{
//                        NSLog(@"saveToURL falied");
//                    }
//                }];
//            }
//        }
//    }
//    
//}
//
//
//
//
//// document ready observer
//- (void) documentInit{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSManagedObjectContext* context = self.document.managedObjectContext;
//        NSError* error;
//        //fetch objects
//        NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
//        request.fetchBatchSize = 10;
//        request.fetchLimit = 100;
//        NSString* nameAttr = @"name";
//        NSString* nameValue = @"Kesong Xie";
//        request.predicate = [NSPredicate predicateWithFormat:@"%K like %@", nameAttr, nameValue];
//        NSArray* users = [context executeFetchRequest:request error: &error];
//        if(error != nil){
//            NSLog(@"%@", error.localizedDescription);
//        }else{
//            if([users count] > 0){
//                for(User* user in users){
//                    self.photos = (NSArray<Photo<MKAnnotation>*>*)user.photo.allObjects;
//                    [self.mapView addAnnotations:self.photos];
//                }
//            }
//        }
//        NSLog(@"%@", self.photos);
//        //        [self.mapView showAnnotations: self.photos animated: YES];
//    });
//    
//}
//
//
////MARK: - UPATE UI
//- (void) updateUI{
//    [self.navigationController.navigationBar setBarTintColor: [UIColor blackColor]];
//    UIFont* titleFont = [UIFont fontWithName: NavigationBarTitleFontName size: NavigationBarTitleFontSize];
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: titleFont,    NSForegroundColorAttributeName: [UIColor whiteColor]}];
//}
//
//- (UIStatusBarStyle) preferredStatusBarStyle{
//    return UIStatusBarStyleLightContent;
//}
//
////MARK: - CLLocationManagerDelegate
////-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
////    if([locations count] > 0){
////        CLLocation* currentLocation = locations.lastObject;
////        MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(LocationDegree, LocationDegree));
////        [self.mapView setRegion:region];
////        [self.locationManager stopUpdatingLocation];
////    }
////}
//
//
////MARK: - MKMapViewDelegate
//-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
//    NSLog(@"just called");
//    
//    if([annotation isKindOfClass:[ MKUserLocation class]]){
//        return nil;
//    }
//    MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier: MapViewReuseIdentifier];
//    if(!annotationView){
//        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MapViewReuseIdentifier];
//    }else{
//        annotationView.annotation = annotation;
//    }
//    UIImage* shot = [[UIImage alloc] initWithContentsOfFile:@"shot3"];
//    annotationView.image = shot;
//    annotationView.frame = CGRectMake(0, 0, 60, 60);
//    annotationView.clipsToBounds = YES;
//    return annotationView;
//}
//
//@end
