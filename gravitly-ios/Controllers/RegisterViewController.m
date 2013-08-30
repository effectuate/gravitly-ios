//
//  RegisterViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/16/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "RegisterViewController.h"
#import "LogInViewController.h"
#import <Parse/Parse.h>

@interface RegisterViewController ()

@end

@implementation RegisterViewController

@synthesize txtUserName;
@synthesize txtPassword;
@synthesize txtEmail;

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
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnRegister:(id)sender {
    NSLog(@"Reistering user to parse");
    NSLog(@"username: %@", txtUserName.text);
    
    PFUser *user = [PFUser user];
    user.username = txtUserName.text;
    user.password = txtPassword.text;
    user.email = txtEmail.text;
    
    // other fields can be set just like with PFObject
    //[user setObject:@"415-392-0202" forKey:@"phone"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"user registered");
            LogInViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
            [self presentViewController:lvc animated:YES completion:nil];
        } else {
            NSLog(@"error");
            //NSLog(@"error: %@", error);
        }
    }];

    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) txtDelegate{
    txtUserName.delegate = self;
    txtPassword.delegate = self;
    txtEmail.delegate = self;
}
@end
