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
#import "PhotoAnnotation.h"


static NSString* const NavigationBarTitleFontName = @"Avenir-Heavy";
static CGFloat const NavigationBarTitleFontSize = 17;
static NSString* const MapViewReuseIdentifier = @"AnnotationViweIden";

static double const Latitude = 32.88831721994364;
static double const Longitude = -117.2413945199151;


static double const Latitude2 = 32.905528;
static double const Longitude2 = -117.242703;




@interface SkyCastViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray* photos;
@property (strong, nonatomic) UIManagedDocument* document;



@end

@implementation SkyCastViewController

- (void) viewDidLoad{
    [super viewDidLoad];
    [self updateUI];
    self.mapView.delegate = self;
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    
    
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* docsDir = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    if(docsDir){
        NSURL* url = [docsDir URLByAppendingPathComponent:@"storage"];
        self.document = [[UIManagedDocument alloc] initWithFileURL: url];
        if(self.document.documentState != UIDocumentStateNormal){
            if([[NSFileManager defaultManager] fileExistsAtPath: url.path]){
                //the document exists, open it
                [self.document openWithCompletionHandler:^(BOOL success){
                    if(success){
                        [self documentInit];
                    }
                }];
            }else{
                //the document does not exist, create one
                [self.document saveToURL:url forSaveOperation: UIDocumentSaveForCreating completionHandler:^(BOOL success){
                    //post a notification that document is ready
                    if(success){
                        NSLog(@"saveToURL succeed");
                        [self documentInit];
                    }else{
                        NSLog(@"saveToURL falied");
                    }
                }];
            }
        }
        
    }

}




// document ready observer
- (void) documentInit{
    NSManagedObjectContext* context = self.document.managedObjectContext;
    Photo* photo1 = [NSEntityDescription insertNewObjectForEntityForName: @"Photo" inManagedObjectContext: context];
    [photo1 setLongitude: Longitude];
    [photo1 setLatitude: Latitude];
    [photo1 setTitle:@"Aerial Shots of Sedona Arizona"];
    [photo1 setThumbnailUrl:@"shot1"];
    
    Photo* photo2 = [NSEntityDescription insertNewObjectForEntityForName: @"Photo" inManagedObjectContext: context];
    [photo2 setLongitude: Longitude2];
    [photo2 setLatitude: Latitude2];
    [photo2 setTitle:@"Beach Walking"];
    [photo2 setThumbnailUrl:@"shot2"];
    
    
    User* user1 = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    [user1 setName:@"Kesong Xie"];
    NSMutableSet* photoSet = [[NSMutableSet alloc] init];
    [photoSet addObject:photo1];
    [photoSet addObject:photo2];
    
    [user1 setPhoto: photoSet];
    
    

    //--fetch
//    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
//    request.fetchBatchSize = 10;
//    request.fetchLimit = 100;
//    NSString* nameAttr = @"name";
//    NSString* nameValue = @"Kesong Xie";
//    request.predicate = [NSPredicate predicateWithFormat:@"%K like %@", nameAttr, nameValue];
//    NSError* error;
//    NSArray* users = [context executeFetchRequest: request error: &error];
//    
//    if(users.count > 0){
//        for(User* user in users){
//            for(Photo* photo in user.photo){
//                NSLog(@"%@", photo.title);
//                NSLog(@"%@", photo.thumbnailUrl);
//                NSLog(@"%f", photo.latitude);
//                NSLog(@"%f", photo.longitude);
//            }
//        }
//    }
//   
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
            if(users.count > 0){
                for(User* user in users){
                    self.photos = [[NSMutableArray alloc] init];
                    for(Photo* photo in user.photo){
                        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(photo.latitude, photo.longitude);
                        PhotoAnnotation* myAnnotation = [[PhotoAnnotation alloc]initWithThumbnailUrl: location url: photo.thumbnailUrl];
                        [self.photos insertObject:myAnnotation atIndex:0];
                    }
                }
            }
        }
        [self.mapView addAnnotations:self.photos];
        [self.mapView showAnnotations:self.photos animated:YES];
    });

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


//MARK: - MKMapViewDelegate
-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    NSLog(@"called from viewForAnnotation");
    if([annotation isKindOfClass:[ MKUserLocation class]]){
        return nil;
    }
    MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier: MapViewReuseIdentifier];
    if(!annotationView){
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MapViewReuseIdentifier];
    }else{
        annotationView.annotation = annotation;
    }
    NSString* thumbnailUrl = ((PhotoAnnotation*)annotation).thumbnailUrl;
    UIImage* image = [UIImage imageNamed: thumbnailUrl];
    NSLog(@"%@", image);
    annotationView.image = image;
    annotationView.frame = CGRectMake(0, 0, 60, 60);
    annotationView.clipsToBounds = YES;
    return annotationView;
}

@end
