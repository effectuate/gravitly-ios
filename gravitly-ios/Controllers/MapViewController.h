//
//  MapViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 9/12/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GVBaseViewController.h"
#import "PhotoDetailsViewController.h"
#import "MapLightBoxViewController.h"

@interface MapViewController : GVBaseViewController <MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MapLightBoxViewDelegate>
- (IBAction)myLocation:(id)sender;
- (IBAction)btnBack:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet GVButton *backButton;
@property (strong, nonatomic) IBOutlet GVButton *searchButton;
@property (strong, nonatomic) IBOutlet GVButton *myLocationButton;
@property (strong, nonatomic) IBOutlet GVButton *gridButton;


@end
