//
//  MapViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 9/12/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize mapView;
@synthesize backButton, searchButton, myLocationButton, gridButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customiseButtons];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)myLocation:(id)sender {
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
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

@end
