//
//  SettingsViewController.m
//  gravitly-ios
//
//  Created by geric on 11/11/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "SettingsViewController.h"
#import "GVBaseViewController.h"
#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "GVFlickr.h"

@interface SettingsViewController () {
    PFUser *user;
}

@end

@implementation SettingsViewController

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
    user = [PFUser currentUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnTwitter:(id)sender {
    if (![PFTwitterUtils isLinkedWithUser:user]) {
        [PFTwitterUtils linkUser:user block:^(BOOL succeeded, NSError *error) {
            if ([PFTwitterUtils isLinkedWithUser:user]) {
                NSLog(@"Woohoo, user logged in with Twitter!");
            }
        }];
    }
}

- (IBAction)btnUnlinkTwitter:(id)sender {
    [PFTwitterUtils unlinkUserInBackground:user block:^(BOOL succeeded, NSError *error) {
        if (!error && succeeded) {
            NSLog(@"The user is no longer associated with their Twitter account.");
        }
    }];
}

- (IBAction)btnFacebook:(id)sender {
    if (![PFFacebookUtils isLinkedWithUser:user]) {
        [PFFacebookUtils linkUser:user permissions:nil block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Woohoo, user logged in with Facebook!");
            }
        }];
    }
}

- (IBAction)btnUnlinkFacebook:(id)sender {
    [PFFacebookUtils unlinkUserInBackground:user block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"The user is no longer associated with their Facebook account.");
        }
    }];
}

- (IBAction)btnFlickr:(id)sender
{
    GVFlickr *flickr = [[GVFlickr alloc] init];
    [flickr loginToFlickr];
}

- (IBAction)btnUnlinkFlickr:(id)sender {
    [[PFUser currentUser] removeObjectForKey:@"flickrAuthToken"];
    [[PFUser currentUser] save];
    [[PFUser currentUser] refresh];
    NSLog(@"%@", [[PFUser currentUser] objectForKey:@"flickrAuthToken"]);
}

@end
