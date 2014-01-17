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
#import "NSString+MD5.h"

@interface LogInViewController ()

@end

@implementation LogInViewController {
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    MBProgressHUD *hud;
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
    [self setBackButton:navBar];
    [self setTitle:@"Login to Gravit.ly"];
    [self setNavigationBar:self.navBar title:self.navBar.topItem.title];
    
    SocialMediaAccountsController *sma = [self smaView:@"Login with"];
    [smaView addSubview:sma];
    [smaView setHidden:YES];
    [self customiseFields:signUpTableView];
    //[self setBackButton];
    [forgotLabel setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize];
    //[self setNavigationBar:self.navBar title:self.navBar.topItem.title];    //[backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [sma.facebookButton addTarget:self action:@selector(facebookLogInButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [sma.twitterButton addTarget:self action:@selector(twitterLogInButton:) forControlEvents:UIControlEventTouchUpInside];
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

- (UIView *)setInputAccessoryView:(int)rowNumber
{
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(61, 0, 60, 44.0f);
    [nextButton addTarget:self action:@selector(nextTextfield:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.tag = rowNumber;
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.frame = CGRectMake(0, 0, 60, 44.0f);
    [previousButton addTarget:self action:@selector(previousTextfield:) forControlEvents:UIControlEventTouchUpInside];
    [previousButton setTitle:@"Prev" forState:UIControlStateNormal];
    previousButton.tag = rowNumber;
    
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake((self.view.frame.size.width)-60, 0, 60, 44.0f);
    [doneButton addTarget:self action:@selector(doneTextfield:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    
    if(rowNumber == 0)
    {
        [previousButton setEnabled:NO];
        [previousButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    if(rowNumber == 1)
    {
        [nextButton setEnabled:NO];
        [nextButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 44.0f)];
    accessoryView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.6f];
    [accessoryView addSubview:nextButton];
    [accessoryView addSubview:previousButton];
    [accessoryView addSubview:doneButton];
    return accessoryView;
}

- (void)doneTextfield:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        GVTableCell *cell = (GVTableCell *)[signUpTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
        [self.view endEditing:YES];
        [cell.textField resignFirstResponder];
}
}

- (void)previousTextfield:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        GVTableCell *cell = (GVTableCell *)[signUpTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(button.tag)-1 inSection:0]];
        [self.view endEditing:YES];
        [cell.textField becomeFirstResponder];
    }
}

- (void)nextTextfield:(id)sender
{
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        GVTableCell *cell = (GVTableCell *)[signUpTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(button.tag)+1 inSection:0]];
        [self.view endEditing:YES];
        [cell.textField becomeFirstResponder];
    }
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
            //[cell.textField setText:@"eli123"];
            usernameTextField = cell.textField;
            usernameTextField.inputAccessoryView = [self setInputAccessoryView:indexPath.row];
            usernameTextField.delegate = self;
            [cell.imageView setImage:[UIImage imageNamed:@"user.png"]];
            break;
        case 1:
            [cell.textField setPlaceholder:@"Password"];
            //[cell.textField setText:@"5f4dcc3b5aa765d61d8327deb882cf99"];
            //[cell.textField setText:@"123"];
            [cell.textField setSecureTextEntry:YES];
            passwordTextField = cell.textField;
            passwordTextField.inputAccessoryView = [self setInputAccessoryView:indexPath.row];
            passwordTextField.delegate = self;
            [cell.imageView setImage:[UIImage imageNamed:@"key.png"]];
            break;
        default:
            break;
    }
    
    return cell;
}

- (IBAction)btnLogIn:(id)sender {
    NSString *password = [passwordTextField.text md5Value];
    
    [PFUser logInWithUsernameInBackground:usernameTextField.text password:password block:^(PFUser *user, NSError *error) {
        if (user) {
            NSLog(@"welcome user");
            [self successfulLogin];
            [hud removeFromSuperview];
        } else {
            NSLog(@"error logging in error: %@", error.description);
            [hud removeFromSuperview];
            if (error.code == 100) {
                Reachability* wifiReach = [Reachability reachabilityForLocalWiFi];
                
                NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
                
                if (netStatus!=ReachableViaWiFi)
                {
                    [[[UIAlertView alloc] initWithTitle:@"Gravit.ly"
                                                message:@"No Internet Connection. Please try again."
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles: nil] show];

                }
                
            } else {
                
                [[[UIAlertView alloc] initWithTitle:@"Gravit.ly"
                                            message:@"Incorrect Username and Password combination."
                                           delegate:self
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles: nil] show];

            }

        }
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1)
    {
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General&path=Network"]];
    }
}

- (void)facebookLogInButton:(id)sender {
    /*NSLog(@"logging in using facebook");
    
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
    }];*/
}

- (void) twitterLogInButton:(id)sender {
    /*NSLog(@"log-in using twitter");
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
            [self successfulLogin];
        } else {
            NSLog(@"User logged in with Twitter!");
            [self successfulLogin];
        }     
    }];*/
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
    //[self slideFrame:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //[self slideFrame:NO];
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
