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

static double const LocationDegree = 0.05;
static NSString* const NavigationBarTitleFontName = @"Avenir-Heavy";
static CGFloat const NavigationBarTitleFontSize = 17;
static NSString* const MapViewReuseIdentifier = @"AnnotationViweIden";
static const NSString *playerItemContext;


//static double const Latitude = 32.88831721994364;
//static double const Longitude = -117.2413945199151;
//static double const Latitude2 = 32.905528;
//static double const Longitude2 = -117.242703;

static NSString* const email1 = @"kesongxie@skypixel.com";

@interface SkyCastViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSMutableArray* photos;

@property (strong, nonatomic) CLLocationManager* locationManager;

@property (strong, nonatomic) NSMutableArray<VideoStream*>* videoStreamAnnotations;


@property (strong, nonatomic) AVAsset* asset;

@property (strong, nonatomic) AVPlayerItem* playerItem;

@property (strong, nonatomic) AVPlayer* player;

@property (strong, nonatomic) PlayerView* playerView;

//create a video stream record
- (CKRecord*) getVideoStreamRecord: (NSString*)title fromLocation: (CLLocation*)location isLive: (NSInteger)live whoShot: (CKReference*)user clipAsset: (CKAsset*) asset;

//create a asset from file info
- (CKAsset*) getCKAssetFromFileName: (NSString*)filename withExtension:(NSString*)ext inDirectory: (NSString*)dir;

- (void) fetchLive;

- (void) createEntries;

- (void) syncUI;

- (void) prepareToPlayWithURL: (NSURL*)url;

@end

@implementation SkyCastViewController

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
        [self fetchLive];
        
      //  [self createEntries];
    }
    
}

- (void) createEntries{
    //create a user
    CKRecord* user = [[CKRecord alloc] initWithRecordType:@"user"];
    user[@"fullname"] = @"Kesong Xie";
    user[@"email"] = email1;
    user[@"avator"] = [self getCKAssetFromFileName:@"avator1" withExtension:@"png" inDirectory:@"avator"];
    CKDatabase* publicDb = [[CKContainer defaultContainer] publicCloudDatabase];
    [publicDb saveRecord:user completionHandler:^(CKRecord* record, NSError* error){
        if(error == nil){
            CKRecord* user = record;
                if(user){
                    //create a videostream record
                    CKRecord* videoStreamRecord1 = [self getVideoStreamRecord: @"Aerial Shots of Sedona Arizona" fromLocation:[[CLLocation alloc] initWithLatitude:32.88831721994364 longitude: -117.2413945199151] isLive:1 whoShot:[[CKReference alloc] initWithRecord:user action:CKReferenceActionDeleteSelf] clipAsset:[self getCKAssetFromFileName:@"clip1" withExtension:@"mp4" inDirectory:@"clip"]];
                    CKRecord* videoStreamRecord2 = [self getVideoStreamRecord: @"Beach Walk Sunset" fromLocation:[[CLLocation alloc] initWithLatitude:32.905528 longitude: -117.242703] isLive:1 whoShot:[[CKReference alloc] initWithRecord:user action:CKReferenceActionDeleteSelf] clipAsset:[self getCKAssetFromFileName:@"clip2" withExtension:@"mp4" inDirectory:@"clip"]];
                    NSArray<CKRecord*>* recordToBeSaved = @[videoStreamRecord1, videoStreamRecord2];
                    
                    //configure the CKModifyRecordsOperation and save multiple records
                    CKDatabase* publicDB = [[CKContainer defaultContainer] publicCloudDatabase];
                    CKModifyRecordsOperation* saveOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:recordToBeSaved recordIDsToDelete:nil];
                    saveOperation.database = publicDB;
                    saveOperation.atomic = NO;
                    saveOperation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> *savedRecords, NSArray<CKRecordID *> *deletedRecordIDs, NSError *operationError){
                        NSLog(@"%@", savedRecords);
                    };
                    NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
                    
                    //save records
                    [operationQueue addOperation:saveOperation];
                }
        }else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];




}



- (CKRecord*) getVideoStreamRecord: (NSString*)title fromLocation: (CLLocation*)location isLive: (NSInteger)live whoShot: (CKReference*)user clipAsset: (CKAsset*) asset  {
    CKRecord* videoStreamRecord = [[CKRecord alloc] initWithRecordType:@"videostream"];
    videoStreamRecord[@"title"] = title;
    videoStreamRecord[@"location"] = location;
    videoStreamRecord[@"live"] = [[NSNumber alloc] initWithInt:live];
    videoStreamRecord[@"user"] = user;
    videoStreamRecord[@"video"] = asset;
    return videoStreamRecord;
}


- (CKAsset*) getCKAssetFromFileName: (NSString*)filename withExtension:(NSString*)ext inDirectory: (NSString*)dir{
    NSString* pathname = [[NSBundle mainBundle] pathForResource:filename ofType: ext inDirectory:dir];
    if(pathname){
        NSURL* url = [[NSURL alloc] initFileURLWithPath:pathname];
        if(url){
            CKAsset* asset = [[CKAsset alloc] initWithFileURL:url];
            return asset;
        }
    }
    return nil;
}

- (void) fetchLive {
    //start loading drone flying user
    CKDatabase* publicDB = [[CKContainer defaultContainer] publicCloudDatabase];
    NSString* liveAttrName = @"live";
    NSNumber* liveValue = [[NSNumber alloc] initWithInt:1];
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @" %K = %@", liveAttrName, liveValue];
    CKQuery* query = [[CKQuery alloc] initWithRecordType:@"videostream" predicate: predicate];
    [publicDB performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord*>* records, NSError* error){
        if(error == nil){
            if(records){
                self.videoStreamAnnotations = [[NSMutableArray alloc]init];
                for(CKRecord* record in records){
                    CKReference* userReference = record[@"user"];
                    CLLocation* location = record[@"location"];
                    CKAsset* videoAsset = record[@"video"];
                    
                    CKRecordID * recordId = userReference.recordID;
                    [publicDB fetchRecordWithID:recordId completionHandler:^(CKRecord* userRecord, NSError* error){
                        if(error == nil){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                CKAsset* avatorAsset = userRecord[@"avator"];
                                User* user =  [[User alloc] init:userRecord[@"fullname"] emailAddress:userRecord[@"email"] avatorUrl:avatorAsset.fileURL];
                                VideoStream* videoStream = [[VideoStream alloc] init:record[@"title"] broadcastUser:user videoStreamUrl:videoAsset.fileURL streamLocation:location];
                                [self.videoStreamAnnotations insertObject:videoStream atIndex:0];
                                [self.mapView addAnnotations: self.videoStreamAnnotations];
                            });
                        }
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

- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


//MARK: - Audio player
- (void) syncUI{
    if ((self.player.currentItem != nil) &&
        ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
        [self.player play];
    }
}


- (void) prepareToPlayWithURL: (NSURL*)url {
    // Create asset to be played
    NSURL* viedoURL = [self videoURL:url];
    AVAsset* asset = [AVAsset assetWithURL:viedoURL];
    
    self.asset = asset;
    
    // Create a new AVPlayerItem with the asset and an
    // array of asset keys to be automatically loaded
    NSArray* assetKeys = @[@"playable", @"hasProtectedContent"];
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:self.asset automaticallyLoadedAssetKeys:assetKeys];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew  context: &playerItemContext];
    
    // Associate the player item with the player
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    self.playerView.player = self.player;
}



- (NSURL *)videoURL: (NSURL*)fileURL {
    return [self createHardLinkToVideoFile: fileURL];
}

//returns a hard link
- (NSURL *)createHardLinkToVideoFile: (NSURL*)fileURL {
    NSError *err;
    NSURL* hardURL = [fileURL URLByAppendingPathExtension:@"mp4"];
    if (![hardURL checkResourceIsReachableAndReturnError:nil]) {
        if (![[NSFileManager defaultManager] linkItemAtURL: fileURL toURL: hardURL error:&err]) {
            // if creating hard link failed it is still possible to create a copy of self.asset.fileURL and return the URL of the copy
        }
    }
    return hardURL;
}

//The paramter is the CKAsset fileURL
- (void)removeHardLinkToVideoFile: (NSURL*)fileURL {
    NSError *err;
    NSURL* hardURL = [fileURL URLByAppendingPathExtension:@"MP4"];
    if ([hardURL checkResourceIsReachableAndReturnError:nil]) {
        if (![[NSFileManager defaultManager] removeItemAtURL:hardURL error:&err]) {
        }
    }
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &playerItemContext) {
        dispatch_async(dispatch_get_main_queue(),^{
            [self syncUI];
        });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    return;
    
}




//MARK: - CLLocationManagerDelegate
-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        [manager startUpdatingLocation];
        //[self createEntries];
        [self fetchLive];
    }else{
        NSLog(@"Location not authorized");
    }
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if([locations count] > 0){
        CLLocation* currentLocation = locations.lastObject;
        MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(LocationDegree, LocationDegree));
        [self.mapView setRegion:region];
        [manager stopUpdatingLocation];
    }
}


//MARK: - MKMapViewDelegate
-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if([annotation isKindOfClass:[ MKUserLocation class]]){
        return nil;
    }
    MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier: MapViewReuseIdentifier];
    if(!annotationView){
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MapViewReuseIdentifier];
        VideoStream* videoStream = (VideoStream*)annotation;
        User* user = videoStream.user;
        NSData* imageData = [[NSData alloc]initWithContentsOfURL:user.avatorUrl];
        UIImage* image = [[UIImage alloc] initWithData: imageData];
        
        annotationView.image = image;
        annotationView.frame = CGRectMake(0, 0, 56, 56);
        annotationView.layer.borderColor = [[UIColor whiteColor] CGColor];
        annotationView.layer.borderWidth = 2.0;
        annotationView.backgroundColor = [UIColor whiteColor];
        
        annotationView.canShowCallout = YES;
        CGRect frame = CGRectMake(0, 0, 80, 50);
        self.playerView = [[PlayerView alloc] initWithFrame:frame];
        self.playerView.backgroundColor = [UIColor blackColor];
        annotationView.leftCalloutAccessoryView = self.playerView;
        
        
        
        
    }else{
        annotationView.annotation = annotation;
    }
    
    return annotationView;
}

-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    VideoStream* videoStream = (VideoStream*)view.annotation;
    [self prepareToPlayWithURL:videoStream.url];
}



@end

