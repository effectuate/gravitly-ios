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

@implementation RegisterViewController

@synthesize txtUserName;
@synthesize txtPassword;
@synthesize txtEmail;
@synthesize signUpTableView;
@synthesize signUpButton;

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
    [self customizeTable:signUpTableView];
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

#pragma mark - Table Delegates and Data Source

- (void)customizeTable: (UITableView *)tableView {
    [tableView setScrollEnabled:NO];
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
    
    switch (indexPath.row) {
        case 0:
            [cell.textField setPlaceholder:@"Username"];
            [cell.imageView setImage:[UIImage imageNamed:@"user.png"]];
            break;
        case 1:
            [cell.textField setPlaceholder:@"Password"];
            [cell.imageView setImage:[UIImage imageNamed:@"key.png"]];
            break;
        case 2:
            [cell.textField setPlaceholder:@"Name"];
            break;
        case 3:
            [cell.textField setPlaceholder:@"Email"];
            break;
        case 4:
            [cell.textField setPlaceholder:@"Phone Number (optional)"];
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end
