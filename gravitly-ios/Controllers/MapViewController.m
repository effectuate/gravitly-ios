//
//  MapViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 9/12/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "MapViewController.h"
#import <Parse/Parse.h>

@interface MapViewController ()

@property (strong, nonatomic) UIView *lightBoxView;

@end

@implementation MapViewController

@synthesize mapView;
@synthesize backButton, searchButton, myLocationButton, gridButton;
@synthesize lightBoxView = _lightBoxView;

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
        frame.size.width = frame.size.width - (20 * 2);
        frame.size.height = frame.size.height - (20 * 2);
        frame.origin.x = frame.origin.x + 20;
        frame.origin.y = frame.origin.y + 20;
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
    
    
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = mapView.userLocation.location.coordinate;
    point.title = @"middle of nowwhere";
    point.subtitle = @"I'm here!!!";
    [self.mapView addAnnotation:point];
    
    [self queryandplot];
}

- (void)addAnnotations:(NSArray *)annotations {
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)myLocation:(id)sender {
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = mapView.userLocation.coordinate;
    point.title = @"Where am I?";
    point.subtitle = @"I'm here!!!";
    [self.mapView addAnnotation:point];
    
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
    static NSString * const identifier = @"MyCustomAnnotation";
    
    MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (annotationView)
    {
        annotationView.annotation = annotation;
    }
    else
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
reuseIdentifier:identifier];
    }
    
    
    
    annotationView.image = [UIImage imageNamed:@"map-marker.png"];
    
    GVLabel *label = [[GVLabel alloc] initWithFrame:annotationView.bounds];
    label.frame = CGRectSetY(label.frame, -5);
    [label setText:@"x"];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setLabelStyle:GVRobotoCondensedBoldDarkColor size:kgvFontSize16];
    
    [annotationView addSubview:label];
    
    annotationView.canShowCallout = YES;
    
    // if you add QuartzCore to your project, you can set shadows for your image, too
    //
    // [annotationView.layer setShadowColor:[UIColor blackColor].CGColor];
    // [annotationView.layer setShadowOpacity:1.0f];
    // [annotationView.layer setShadowRadius:5.0f];
    // [annotationView.layer setShadowOffset:CGSizeMake(0, 0)];
    // [annotationView setBackgroundColor:[UIColor whiteColor]];
    
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
            NSString *photoCaption = [object objectForKey:@"caption"];
            point.title = photoCaption;
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


@end
