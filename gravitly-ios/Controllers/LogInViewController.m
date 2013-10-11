//
//  LogInViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "SocialMediaAccountsController.h"
#import "GVTableCell.h"

@interface LogInViewController ()

@end

@implementation LogInViewController {
    UITextField *usernameTextField;
    UITextField *passwordTextField;
}

@synthesize smaView;
@synthesize signUpTableView;
@synthesize navBar;
@synthesize forgotLabel;

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
    SocialMediaAccountsController *sma = [self smaView:@"Login with"];
    [smaView addSubview:sma];
    [self customiseFields:signUpTableView];
    [self setBackButton];
    [forgotLabel setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize];
    [self setNavigationBar:self.navBar title:self.navBar.topItem.title];    //[backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [sma.facebookButton addTarget:self action:@selector(facebookLogInButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table Delegates and Data Source

- (void)customiseFields: (UITableView *)tableView {
    [self customiseTable:tableView];
    [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    GVTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"GVTableCell" owner:self options:nil];
        cell = (GVTableCell *)[nibs objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    switch (indexPath.row) {
        case 0:
            [cell.textField setPlaceholder:@"Username"];
            [cell.textField setText:@"eli"];
            usernameTextField = cell.textField;
            usernameTextField.delegate = self;
            [cell.imageView setImage:[UIImage imageNamed:@"user.png"]];
            break;
        case 1:
            [cell.textField setPlaceholder:@"Password"];
            [cell.textField setText:@"eli"];
            [cell.textField setSecureTextEntry:YES];
            passwordTextField = cell.textField;
            passwordTextField.delegate = self;
            [cell.imageView setImage:[UIImage imageNamed:@"key.png"]];
            break;
        default:
            break;
    }
    
    return cell;
}

- (IBAction)btnLogIn:(id)sender {
    
    [PFUser logInWithUsernameInBackground:usernameTextField.text password:passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            NSLog(@"welcome user");
            [self successfulLogin];
        } else {
            NSLog(@"error logging in error: %@", error.description);
            
        }
    }];
}

- (void)facebookLogInButton:(id)sender {
    NSLog(@"logging in using facebook");
    
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self successfulLogin];
        } else {
            NSLog(@"User with facebook logged in!");
            [self successfulLogin];
        }
        
        NSLog(@"%@", error);
    }];
    
    
}

- (void) successfulLogin {
    
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StartController"];
    [self presentViewController:vc animated:YES completion:nil];
    
    NSLog(@"must present camera tab after login");
    /*
    UITabBarController *aa =[self.storyboard instantiateViewControllerWithIdentifier:@"StartController"];
    aa.selectedIndex = 1;
    [self presentViewController:aa animated:YES completion:nil];
    */
}

#pragma mark - Back button methods

- (void)setBackButton
{
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(5, 5, 32, 32)];
    [navBar addSubview:backButton];
}

- (void)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Textfield delegates

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self slideFrame:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self slideFrame:NO];
}

- (void)slideFrame:(BOOL)up
{
    const int movementDistance = 140;
    const float movementDuration = 0.3f;
    int movement = (up ? -movementDistance : movementDistance);
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

@end
