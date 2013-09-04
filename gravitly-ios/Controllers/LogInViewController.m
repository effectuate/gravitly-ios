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


    switch (indexPath.row) {
        case 0:
            [cell.textField setPlaceholder:@"Username"];
            usernameTextField = cell.textField;
            [cell.imageView setImage:[UIImage imageNamed:@"user.png"]];
            break;
        case 1:
            [cell.textField setPlaceholder:@"Password"];
            [cell.textField setSecureTextEntry:YES];
            passwordTextField = cell.textField;
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
            UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
            [self presentViewController:vc animated:YES completion:nil];
        } else {
            NSLog(@"error logging in error: %@", error.description);
            
        }
    }];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)setBackButton
{
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    NSLog(@"-----> %@", self.navigationItem);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*-(void) txtDelegate {
    txtPassword.delegate = self;
    txtUserName.delegate = self;
}*/


@end
