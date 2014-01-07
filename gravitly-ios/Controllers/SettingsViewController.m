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
#import "GVTumblr.h"
#import <TMAPIClient.h>
//#import "OAuthConsumer.h"

@interface SettingsViewController () {
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
            if ([PFFacebookUtils isLinkedWithUser:user]) {
                [cell.button setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
            }
            [cell.button addTarget:self action:@selector(connectFacebook:) forControlEvents:UIControlEventTouchUpInside];
            [cell.label setText:@"Facebook"];
            break;
        case 1:
            if ([PFTwitterUtils isLinkedWithUser:user]) {
                [cell.button setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
            }
            [cell.button addTarget:self action:@selector(connectTwitter:) forControlEvents:UIControlEventTouchUpInside];
            [cell.label setText:@"Twitter"];
            break;
        case 2:
            if ([GVFlickr isLinkedWithUser:user]) {
                [cell.button setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
            }
            [cell.button addTarget:self action:@selector(connectFlickr:) forControlEvents:UIControlEventTouchUpInside];
            [cell.label setText:@"Flickr"];
            break;
        case 3:
            [cell.button addTarget:self action:@selector(connectTumblr:) forControlEvents:UIControlEventTouchUpInside];
            [cell.label setText:@"Tumblr"];
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Social Networks

- (void)connectFacebook:(UIButton *)sender
{
    sender.enabled = NO;
    if (![PFFacebookUtils isLinkedWithUser:user]) {
        [PFFacebookUtils linkUser:user permissions:nil block:^(BOOL succeeded, NSError *error) {
            NSString *msg;
            if (succeeded) {
                msg = [NSString stringWithFormat:@"Facebook account successfully linked."];
            } else {
                msg = [NSString stringWithFormat:@"%@", error.debugDescription];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alertView show];
            [sender setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        }];
    } else {
        [PFFacebookUtils unlinkUserInBackground:user block:^(BOOL succeeded, NSError *error) {
            NSString *msg;
            if (succeeded) {
                msg = [NSString stringWithFormat:@"Facebook account unlinked."];
            } else {
                msg = [NSString stringWithFormat:@"%@", error.debugDescription];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alertView show];
            [sender setImage:[UIImage imageNamed:@"check-disabled.png"] forState:UIControlStateNormal];
        }];
    }
    sender.enabled = YES;
}

- (void)connectTwitter:(UIButton *)sender
{
    sender.enabled = NO;
    if (![PFTwitterUtils isLinkedWithUser:user]) {
        [PFTwitterUtils linkUser:user block:^(BOOL succeeded, NSError *error) {
            NSString *msg;
            if (succeeded) {
                msg = [NSString stringWithFormat:@"Twitter account successfully linked."];
            } else {
                msg = [NSString stringWithFormat:@"%@", error.debugDescription];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alertView show];
            [sender setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        }];
    } else {
        [PFTwitterUtils unlinkUserInBackground:user block:^(BOOL succeeded, NSError *error) {
            NSString *msg;
            if (succeeded) {
                msg = [NSString stringWithFormat:@"Twitter account unlinked."];
            } else {
                msg = [NSString stringWithFormat:@"%@", error.debugDescription];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alertView show];
            [sender setImage:[UIImage imageNamed:@"check-disabled.png"] forState:UIControlStateNormal];
        }];
    }
    sender.enabled = YES;

}

- (void)connectFlickr:(UIButton *)sender
{
    sender.enabled = NO;
    if (![GVFlickr isLinkedWithUser:user]) {
        GVFlickr *flickr = [[GVFlickr alloc] init];
        [flickr loginToFlickr];
        NSString *msg = [NSString stringWithFormat:@"Flickr account successfully linked."];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alertView show];
        [sender setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    } else {
        [GVFlickr unlinkUser:user];
        NSString *msg = [NSString stringWithFormat:@"Flickr account unlinked."];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alertView show];
        [sender setImage:[UIImage imageNamed:@"check-disabled.png"] forState:UIControlStateNormal];
    }
    sender.enabled = YES;
}

- (void)connectTumblr:(UIButton *)sender
{
    GVTumblr *tumblr = [[GVTumblr alloc] init];
    [tumblr connectTumblr];
}

@end
