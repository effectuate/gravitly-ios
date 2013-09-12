//
//  MapViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 9/12/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "MapViewController.h"
#import "TabBarViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize mapView;

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
    TabBarViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"StartController"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:fvc];
    [self presentViewController:nav animated:YES completion:nil];
}
@end
