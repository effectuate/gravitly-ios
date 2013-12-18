//
//  SettingsViewController.m
//  gravitly-ios
//
//  Created by geric on 11/11/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "SettingsViewController.h"
#import "GVBaseViewController.h"
#import "GVTableCell.h"

#import "ConnectedSettingsViewController.h"

#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "GVFlickr.h"

@interface SettingsViewController () {
    
    UIButton *connectFacebookButton;
    UIButton *connectTwitterButton;
    
    
    PFUser *user;
}

@end

@implementation SettingsViewController

@synthesize accountsTableView;
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
    [self setBackButton:navBar];
    [self setTitle:@"Connected Accounts"];
    [self setNavigationBar:self.navBar title:self.navBar.topItem.title];
    user = [PFUser currentUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Back button methods

- (void)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table Delegates and Data Source

- (void)customiseFields: (UITableView *)tableView {
    [self customiseTable:tableView];
    [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    
    ConnectedSettingsViewController *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"ConnectedSettings" owner:self options:nil];
        cell = (ConnectedSettingsViewController *)[nibs objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    switch (indexPath.row) {
        case 0:
            [cell.label setText:@"Facebook"];
            break;
        case 1:
            [cell.label setText:@"Google"];
            break;
        case 2:
            [cell.label setText:@"Instagram"];
            break;
        case 3:
            [cell.label setText:@"Twitter"];
            break;
        case 4:
            [cell.label setText:@"Yahoo"];
            //            [cell.textField setPlaceholder:@"Password"];
            //            //[cell.textField setText:@"5f4dcc3b5aa765d61d8327deb882cf99"];
            //            [cell.textField setText:@"password"];
            //            [cell.textField setSecureTextEntry:YES];
            //            passwordTextField = cell.textField;
            //            passwordTextField.delegate = self;
            //            [cell.imageView setImage:[UIImage imageNamed:@"key.png"]];
            
            break;
        default:
            break;
    }
    
    return cell;
}





//- (IBAction)btnCancel:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (IBAction)btnTwitter:(id)sender {
//    if (![PFTwitterUtils isLinkedWithUser:user]) {
//        [PFTwitterUtils linkUser:user block:^(BOOL succeeded, NSError *error) {
//            if ([PFTwitterUtils isLinkedWithUser:user]) {
//                NSLog(@"Woohoo, user logged in with Twitter!");
//            }
//        }];
//    }
//}
//
//- (IBAction)btnUnlinkTwitter:(id)sender {
//    [PFTwitterUtils unlinkUserInBackground:user block:^(BOOL succeeded, NSError *error) {
//        if (!error && succeeded) {
//            NSLog(@"The user is no longer associated with their Twitter account.");
//        }
//    }];
//}
//
//- (IBAction)btnFacebook:(id)sender {
//    if (![PFFacebookUtils isLinkedWithUser:user]) {
//        [PFFacebookUtils linkUser:user permissions:nil block:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                NSLog(@"Woohoo, user logged in with Facebook!");
//            }
//        }];
//    }
//}
//
//- (IBAction)btnUnlinkFacebook:(id)sender {
//    [PFFacebookUtils unlinkUserInBackground:user block:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"The user is no longer associated with their Facebook account.");
//        }
//    }];
//}
//
//- (IBAction)btnFlickr:(id)sender
//{
//    GVFlickr *flickr = [[GVFlickr alloc] init];
//    [flickr loginToFlickr];
//}
//
//- (IBAction)btnUnlinkFlickr:(id)sender {
//    [[PFUser currentUser] removeObjectForKey:@"flickrAuthToken"];
//    [[PFUser currentUser] save];
//    [[PFUser currentUser] refresh];
//    NSLog(@"%@", [[PFUser currentUser] objectForKey:@"flickrAuthToken"]);
//}

@end
