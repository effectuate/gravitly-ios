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

@interface RegisterViewController ()

@end

@implementation RegisterViewController {
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    UITextField *nameTextField;
    UITextField *emailTextField;
    UITextField *phoneNumberTextField;
}

@synthesize txtUserName;
@synthesize txtPassword;
@synthesize txtEmail;
@synthesize signUpTableView;
@synthesize signUpButton;
@synthesize socialMediaAccountsView;
@synthesize navBar;

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
    [self setBackButton];
    [self setTitle:@"Join Gravit.ly"];
    SocialMediaAccountsController *smaView = [self smaView:@"Or, sign up with"];
    [socialMediaAccountsView addSubview:smaView];
    [self customiseFields:signUpTableView];
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
    user.password = passwordTextField.text;
    user.email = emailTextField.text;
    
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

#pragma mark - Table Delegates and Data Source

- (void)customiseFields: (UITableView *)tableView {
    [self customiseTable:tableView];
    [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 224.0f)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
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
            [cell.textField setPlaceholder:@"Name"];
            nameTextField = cell.textField;
            [nameTextField setDelegate:self];
            break;
        case 3:
            [cell.textField setPlaceholder:@"Email"];
            emailTextField = cell.textField;
            [emailTextField setDelegate:self];
            break;
        case 4:
            [cell.textField setPlaceholder:@"Phone Number (optional)"];
            phoneNumberTextField = cell.textField;
            [phoneNumberTextField setDelegate:self];
            break;
            
        default:
            break;
    }
    
    return cell;
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
