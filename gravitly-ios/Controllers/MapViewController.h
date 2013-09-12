//
//  MapViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 9/12/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController
- (IBAction)myLocation:(id)sender;
- (IBAction)btnBack:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
