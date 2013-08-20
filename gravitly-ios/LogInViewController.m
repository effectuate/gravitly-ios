//
//  LogInViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>

@interface LogInViewController ()

@end

@implementation LogInViewController

@synthesize txtUserName;
@synthesize txtPassword;

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
    [self txtDelegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnLogIn:(id)sender {
    NSLog(@"Logging in");
    [PFUser logInWithUsernameInBackground:txtUserName.text password:txtPassword.text block:^(PFUser *user, NSError *error) {
        if (user) {
            NSLog(@"welcome user");
            UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainMenu"];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            NSLog(@"error logging in");
            
        }
    }];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void) txtDelegate {
    txtPassword.delegate = self;
    txtUserName.delegate = self;
}


@end
