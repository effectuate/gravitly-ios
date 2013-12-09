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
#import "GVTableCell.h"
#import "NSString+MD5.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController {
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    UITextField *firstnameTextField;
    UITextField *lastnameTextField;
    UITextField *emailTextField;
    UITextField *phoneNumberTextField;
    BOOL isAgreeChecked;
}

@synthesize txtUserName;
@synthesize txtPassword;
@synthesize txtEmail;
@synthesize signUpTableView;
@synthesize signUpButton;
@synthesize socialMediaAccountsView;
@synthesize navBar;
@synthesize checkButton;

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
    [self setTitle:@"Join Gravit.ly"];
    [self setNavigationBar:self.navBar title:self.navBar.topItem.title];
    SocialMediaAccountsController *smaView = [self smaView:@"Or, sign up with"];
    [socialMediaAccountsView addSubview:smaView];
    [self customiseFields:signUpTableView];
    isAgreeChecked = NO;
    
    [self.signUpButton setEnabled:NO];
    [self.signUpButton setButtonColor:GVButtonGrayColor];
    
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
    user.username = usernameTextField.text;
    user.password = passwordTextField.text.md5Value;
    user.email = emailTextField.text;
    
    // other fields can be set just like with PFObject
    //[user setObject:@"415-392-0202" forKey:@"phone"];
   
    if (isAgreeChecked) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Signing up...";
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"user registered");
                LogInViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
                [hud removeFromSuperview];
                [self presentViewController:lvc animated:YES completion:nil];
            } else {
                
                NSLog(@"error");
                [hud removeFromSuperview];
                //NSLog(@"error: %@", error);
            }
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:@"You must agree to Gravit.ly's Terms and Conditions before signing up" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)checkUsernameIfExist:(NSString *) username {
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"username" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [[[UIAlertView alloc] initWithTitle:@"Gravit.ly"
                                        message:@"Username taken. Please try again."
                                       delegate:self
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles: nil] show];

            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - Table Delegates and Data Source

- (void)customiseFields: (UITableView *)tableView {
    [self customiseTable:tableView];
    [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 264.0f)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
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
            [cell.imageView setImage:[UIImage imageNamed:@"user.png"]];
            usernameTextField = cell.textField;
            [usernameTextField setDelegate:self];
            break;
        case 1:
            [cell.textField setPlaceholder:@"Password"];
            [cell.textField setSecureTextEntry:YES];
            [cell.imageView setImage:[UIImage imageNamed:@"key.png"]];
            passwordTextField = cell.textField;
            [passwordTextField setDelegate:self];
            break;
        case 2:
            [cell.textField setPlaceholder:@"First Name"];
            [cell.textField setSpellCheckingType:UITextSpellCheckingTypeNo];
            firstnameTextField = cell.textField;
            [firstnameTextField setDelegate:self];
            break;
        case 3:
            [cell.textField setPlaceholder:@"Last Name"];
            [cell.textField setSpellCheckingType:UITextSpellCheckingTypeNo];
            lastnameTextField = cell.textField;
            [lastnameTextField setDelegate:self];
            break;
        case 4:
            [cell.textField setPlaceholder:@"Email"];
            emailTextField = cell.textField;
            [emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
            [emailTextField setDelegate:self];
            break;
        case 5:
            [cell.textField setPlaceholder:@"Phone Number (optional)"];
            phoneNumberTextField = cell.textField;
            [phoneNumberTextField setKeyboardType:UIKeyboardTypeDecimalPad];
            [phoneNumberTextField setDelegate:self];
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - Back button methods

//- (void)setBackButton
//{
//    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
//    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [backButton setFrame:CGRectMake(5, 5, 32, 32)];
//    [navBar addSubview:backButton];
//}


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
    textField.placeholder = nil;
    //[self slideFrame:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (usernameTextField == textField) {
        usernameTextField.placeholder = @"Username";
    } else if (passwordTextField == textField) {
        passwordTextField.placeholder = @"Password";
    } else if (firstnameTextField == textField) {
        firstnameTextField.placeholder = @"First Name";
    } else if (lastnameTextField == textField) {
        lastnameTextField.placeholder  = @"Last Name";
    } else if (emailTextField == textField) {
        emailTextField.placeholder = @"Email";
    } else if (phoneNumberTextField == textField) {
        phoneNumberTextField.placeholder = @"Phone Number (optional)";
    }
    
    if ([usernameTextField.text length] > 0 && [passwordTextField.text length] > 0
        && [firstnameTextField.text length] > 0 && [lastnameTextField.text length] > 0
        && [emailTextField.text length] > 0) {
        [self.signUpButton setEnabled:YES];
         [self.signUpButton setButtonColor:GVButtonBlueColor];
    } else {
        [self.signUpButton setEnabled:NO];
         [self.signUpButton setButtonColor:GVButtonGrayColor];
    }
    
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

- (IBAction)btnAgree:(id)sender {
    if (isAgreeChecked == NO) {
        [checkButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        isAgreeChecked = YES;
    } else {
        [checkButton setImage:[UIImage imageNamed:@"check-disabled.png"] forState:UIControlStateNormal];
        isAgreeChecked = NO;
    }
}
@end
