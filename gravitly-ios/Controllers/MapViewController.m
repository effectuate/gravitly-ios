//
//  MapViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 9/12/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "MapViewController.h"
#import <Parse/Parse.h>
#import "ScoutViewController.h"
#import "MainMenuViewController.h"
#import "GVPointAnnotation.h"

static const int feedSize = 15;

@interface MapViewController ()

@property (strong, nonatomic) UIView *lightBoxView;
@property (strong, nonatomic) NMPaginator *paginator;

@end

@implementation MapViewController

@synthesize mapView;
@synthesize backButton, searchButton, myLocationButton, gridButton;
@synthesize lightBoxView = _lightBoxView;
@synthesize selectedFeed = _selectedFeed;
@synthesize paginator = _paginator;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Lazy instantiation

-(UIView *)lightBoxView {
    if (!_lightBoxView) {
        CGRect frame = self.view.frame;
        frame.size.width = frame.size.width - (19 * 2);
        frame.size.height = frame.size.height - (19 * 2);
        frame.origin.x = frame.origin.x + 19;
        frame.origin.y = frame.origin.y + 19;
        _lightBoxView = [[UIView alloc] initWithFrame:frame];
    }
    return _lightBoxView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customiseButtons];
	// Do any additional setup after loading the view.
    
    [mapView setDelegate:self];
    
    // Setting the map type
    [self.mapView setMapType:MKMapTypeSatellite];
    
    // plotting of feeds
    self.paginator = [self setupPaginator];
    [self.paginator fetchFirstPage];
    
    if (self.selectedFeed != nil) {
        [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
        
        CLLocationCoordinate2D coordsGarage = CLLocationCoordinate2DMake(self.selectedFeed.latitude, self.selectedFeed.longitude);
        MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:coordsGarage fromEyeCoordinate:coordsGarage eyeAltitude:1000];
        [self.mapView setCamera:camera animated:YES];
    }
}

- (void)addAnnotations:(NSArray *)annotations {
    
}

- (IBAction)myLocation:(id)sender {
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    
//    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
//    point.coordinate = mapView.userLocation.coordinate;
//    point.title = @"Where am I?";
//    point.subtitle = @"I'm here!!!";
//    [self.mapView addAnnotation:point];
    
    CLLocationCoordinate2D coordsGarage = mapView.userLocation.coordinate;//CLLocationCoordinate2DMake(39.287546, -76.619355);
    CLLocationCoordinate2D blimpCoord = CLLocationCoordinate2DMake(39.253095, -76.6657);
    
    NSLog(@"-----> Current Location %f %f", mapView.userLocation.coordinate.latitude, mapView.userLocation.coordinate.longitude);
    //MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:coordsGarage fromEyeCoordinate:coordsGarage eyeAltitude:300];
    
    //[self.mapView setCamera:camera animated:YES];
    
}

- (IBAction)btnBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self presentTabBarController:self];
}

#pragma mark - Button customisations

- (void)customiseButtons {
    [backButton setButtonColor:GVButtonDarkBlueColor];
    [searchButton setButtonColor:GVButtonDarkBlueColor];
    [myLocationButton setButtonColor:GVButtonDarkBlueColor];
    [gridButton setButtonColor:GVButtonDarkBlueColor];
    
    [backButton addTarget:self action:@selector(btnBack:) forControlEvents:UIControlEventTouchUpInside];
    [myLocationButton addTarget:self action:@selector(myLocation:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Map Annotations

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPointAnnotation *point = (MKPointAnnotation *)annotation;
    
    static NSString * const identifier = @"MyCustomAnnotation";
    
    MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (annotationView) {
        annotationView.annotation = annotation;
    } else {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:identifier];
    }
    
    if ([point isKindOfClass:[MKPointAnnotation class]]) {
        GVPointAnnotation *pa = (GVPointAnnotation *)point;
        
        NSString *imageString = [NSString stringWithFormat:@"pin_%@.png", pa.feed.activityTagName];
        annotationView.image = [UIImage imageNamed:@"pin.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageString]];
        [annotationView addSubview:imageView];
        
        //GVPointAnnotation *pointAnnotation = (GVPointAnnotation *)point;
        
        GVLabel *label = [[GVLabel alloc] initWithFrame:annotationView.bounds];
        
        label.frame = CGRectSetY(label.frame, -3);
        label.frame = CGRectSetX(label.frame, 30);
        
        [label setText:pa.feed.locationName];
        [label sizeToFit];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.textAlignment = NSTextAlignmentLeft;
        [label setLabelStyle:GVRobotoCondensedBoldDarkColor size:kgvFontSize12];
        
        GVLabel *dateLabel = [[GVLabel alloc] initWithFrame:annotationView.bounds];
        [dateLabel setLabelStyle:GVRobotoCondensedBoldDarkColor size:kgvFontSize10];
        
        NSDateFormatter	*dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd yyyy HH:mm z"];
        NSString *formattedDateString = [dateFormatter stringFromDate:pa.feed.dateUploaded];
        
        [dateLabel setText:formattedDateString];
        [dateLabel sizeToFit];
        dateLabel.frame = CGRectSetY(dateLabel.frame, 11);
        dateLabel.frame = CGRectSetX(dateLabel.frame, 30);
        
        [annotationView addSubview:label];
        [annotationView addSubview:dateLabel];
    }
    
    //annotationView.canShowCallout = YES;
    
    // if you add QuartzCore to your project, you can set shadows for your image, too
    //
    // [annotationView.layer setShadowColor:[UIColor blackColor].CGColor];
    // [annotationView.layer setShadowOpacity:1.0f];
    // [annotationView.layer setShadowRadius:5.0f];
    // [annotationView.layer setShadowOffset:CGSizeMake(0, 0)];
    // [annotationView setBackgroundColor:[UIColor whiteColor]];
    if ([point.title isEqualToString:@"Current Location"]) {
        annotationView = nil;
    }
    
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    ScoutLightBoxView *lightBox = (ScoutLightBoxView *)[[[NSBundle mainBundle] loadNibNamed:@"ScoutLightBoxView" owner:self options:nil] objectAtIndex:0];
//    [lightBox.collectionView setDelegate:self];
//    [lightBox.collectionView setDataSource:self];
//    
//    
//    lightBox.frame = CGRectSetX(lightBox.frame, 20);
//    lightBox.frame = CGRectSetY(lightBox.frame, 20);
//    [self.view addSubview:lightBox];
}


- (void) queryandplot {
    NSLog(@"plotting 1");
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"plotting 2");
        
        NSMutableArray *newPosts = [[NSMutableArray alloc] initWithCapacity:200];
        
        for (PFObject *object in objects) {
            [newPosts addObject:object];
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            
            PFGeoPoint *loccc = [object objectForKey:@"geoPoint"];
            
            CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:loccc.latitude longitude:loccc.longitude];
        
            point.coordinate = objectLocation.coordinate;
            //point.coordinate = mapView.userLocation.location.coordinate;
            //point.title = [object objectForKey:@"caption"];
            //point.subtitle = @"I'm here!!!";
            [self.mapView addAnnotation:point];
        }
        NSLog(@"size: %i", newPosts.count);
    }];
    
}

#pragma mark - Button actions

- (IBAction)btnCollectionView:(id)sender {
    MapLightBoxViewController *mlbvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapLightBoxViewController"];
    [mlbvc setDelegate:self];
    
    mlbvc.view.frame = self.lightBoxView.bounds;
    [mlbvc willMoveToParentViewController:self];
    [self.lightBoxView addSubview:mlbvc.view];
    [self addChildViewController:mlbvc];
    [mlbvc didMoveToParentViewController:self];
    
    [self.view addSubview:self.lightBoxView];
}

#pragma mark - MapLightBox delegate

- (void)lightBoxDidClose {
    [self.lightBoxView removeFromSuperview];
    self.lightBoxView = nil;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%lu",(unsigned long)self.supportedInterfaceOrientations);
}

//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}

#pragma mark - MKMapViewDelegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //if scouting, then update paginator
    if ([self.presentingViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *presentingVC = (UITabBarController *)self.presentingViewController;
        Class class = [[presentingVC selectedViewController] class];
        if (class == [ScoutViewController class]) {
            [self.paginator reset];
            GVNearestPhotoFeedPaginator *npfp = [[GVNearestPhotoFeedPaginator alloc] initWithPageSize:feedSize delegate:self];
            npfp.selectedLatitude = userLocation.location.coordinate.latitude;
            npfp.selectedLongitude = userLocation.location.coordinate.longitude;
            self.paginator = npfp;
            [self fetchNextPage];
        }
    }

}


#pragma mark - Paginator methods

- (NMPaginator *)setupPaginator {
    NMPaginator *paginator = nil;
    if ([self.presentingViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *presentingVC = (UITabBarController *)self.presentingViewController;
        Class class = [[presentingVC selectedViewController] class];
        if (class == [ScoutViewController class]) {
            NSLog(@"================= SCOUT");
            GVNearestPhotoFeedPaginator *npfp = [[GVNearestPhotoFeedPaginator alloc] initWithPageSize:feedSize delegate:self];
            npfp.selectedLatitude = mapView.userLocation.location.coordinate.latitude;
            npfp.selectedLongitude = mapView.userLocation.location.coordinate.longitude;
            paginator = npfp;
        } else if (class == [MainMenuViewController class]) {
            NSLog(@"================= MAIN MENU");
            paginator = [[GVPhotoFeedPaginator alloc] initWithPageSize:feedSize delegate:self];
        } else {
            NSLog(@"No parent, default paginator");
        }
    }
    return paginator;
}

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    [self plotFeeds];
    [self fetchNextPage];
}

- (void)fetchNextPage {
    [self.paginator fetchNextPage];
}


-(void)plotFeeds
{
    for (id f in self.paginator.results) {
        if ([f isKindOfClass:[Feed class]]) {
            Feed *feed = (Feed *)f;
            GVPointAnnotation *point = [[GVPointAnnotation alloc] init];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:feed.latitude
                                                                    longitude:feed.longitude];
            point.coordinate = location.coordinate;
            point.title = feed.locationName;
            point.subtitle = feed.activityTagName;
            point.feed = feed;

            
            if (![NSThread isMainThread])
            {
                if (!feed.latitude == 0.0f && !feed.longitude == 0.0f) { //equator
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.mapView addAnnotation:point];
                    });
                }
            } else {
                [self.mapView addAnnotation:point];
            }
            
        }
    }
}


@end
