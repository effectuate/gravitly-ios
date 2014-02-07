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
#import "TabBarViewController.h"

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
    [self adjustHeightOfTableView];
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

-(void) adjustHeightOfTableView
{
    CGRect frame = self.accountsTableView.frame;
    frame.size.height = self.accountsTableView.rowHeight*4;
    self.accountsTableView.frame = frame;
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
                [sender setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
                
                NSString *requestString = @"me/?fields=name,location,gender,birthday,relationship_status,picture,email,id";
                 
                 FBRequest *request = [[FBRequest alloc] initWithSession:[FBSession activeSession] graphPath:requestString];
                
                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    NSDictionary *userData = (NSDictionary *)result;
                    if (userData[@"id"] != nil) {
                        [self getFacebookPicture:userData[@"id"]];
                    }
                }];
                
            } else {
                msg = [NSString stringWithFormat:@"%@", [error.userInfo objectForKey:@"error"]];
                [[FBSession activeSession] closeAndClearTokenInformation];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alertView show];
        }];
    } else {
        [PFFacebookUtils unlinkUserInBackground:user block:^(BOOL succeeded, NSError *error) {
            NSString *msg;
            if (succeeded) {
                msg = [NSString stringWithFormat:@"Facebook account unlinked."];
                [sender setImage:[UIImage imageNamed:@"check-disabled.png"] forState:UIControlStateNormal];
            } else {
                msg = [NSString stringWithFormat:@"%@", [error.userInfo objectForKey:@"error"]];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alertView show];
        }];
    }
    sender.enabled = YES;
}

- (void)getFacebookPicture: (NSString *)facebookId
{
    NSString *type = @"large"; //small, normal, large, square
    NSString *pictureURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=%@", facebookId, type];
    //NSURL *pictureURL = [NSURL URLWithString:pictureURLString];
    
    //NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
    //NSString *fileName = [NSString stringWithFormat:@"%@.jpeg", facebookId];
    //PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
    
    [[PFUser currentUser] setObject:pictureURLString forKey:@"picFacebookURL"];
    [[PFUser currentUser] saveInBackground];
}

- (void)getTwitterPicture
{
    NSURL *pictureURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pictureURL];
    [[PFTwitterUtils twitter] signRequest:request];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (!error) {
        NSString *pictureURLString = json[@"profile_image_url"];
        pictureURLString = [pictureURLString stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]; // bigger image 73px by 73px
        [[PFUser currentUser] setObject:pictureURLString forKey:@"picTwitterURL"];
        [[PFUser currentUser] saveInBackground];
        //NSURL *pictureURL = [NSURL URLWithString:pictureURLString];
        
        //NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
        
        /*NSString *fileName = json[@"screen_name"];
        PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpeg", fileName] data:imageData];
        
        [[PFUser currentUser] setObject:imageFile forKey:@"picTwitter"];
        [[PFUser currentUser] saveInBackground];*/
    }
    
}

- (void)connectTwitter:(UIButton *)sender
{
    sender.enabled = NO;
    if (![PFTwitterUtils isLinkedWithUser:user]) {
        [PFTwitterUtils linkUser:user block:^(BOOL succeeded, NSError *error) {
            NSString *msg;
            if (succeeded) {
                msg = [NSString stringWithFormat:@"Twitter account successfully linked."];
                [sender setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
                [self getTwitterPicture];
            } else {
                msg = [NSString stringWithFormat:@"%@", [error.userInfo objectForKey:@"error"]];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alertView show];
        }];
    } else {
        [PFTwitterUtils unlinkUserInBackground:user block:^(BOOL succeeded, NSError *error) {
            NSString *msg;
            if (succeeded) {
                msg = [NSString stringWithFormat:@"Twitter account unlinked."];
            } else {
                msg = [NSString stringWithFormat:@"%@", [error.userInfo objectForKey:@"error"]];
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
    [TMAPIClient sharedInstance].OAuthConsumerKey = TUMBLR_CLIENT_KEY;
    [TMAPIClient sharedInstance].OAuthConsumerSecret = TUMBLR_CLIENT_SECRET;
    
    [[TMAPIClient sharedInstance] authenticate:@"gravitly" callback:^(NSError *error) {
        if (error) {
            NSLog(@"Authentication failed: %@ %@", error, [error description]);
        } else {
            NSLog(@"Authentication successful!");
            NSLog(@"%@", [TMAPIClient sharedInstance].OAuthTokenSecret);
            NSLog(@"%@", [TMAPIClient sharedInstance].OAuthToken);
            
            [[TMAPIClient sharedInstance] photo:@"elidc93bubonicplague"
                                  filePathArray:@[[[NSBundle mainBundle] pathForResource:@"blue" ofType:@"png"]]
                               contentTypeArray:@[@"image/png"]
                                  fileNameArray:@[@"blue.png"]
                                     parameters:@{@"caption" : @"Caption"}
                                       callback:^(id response, NSError *error) {
                                           if (error)
                                               NSLog(@"Error posting to Tumblr %@", error.localizedDescription);
                                           else
                                               NSLog(@"Posted to Tumblr");
                                       }];
        }
    }];
    
}

-(NSURLRequest *)createTumblrRequest:(NSDictionary *)postKeys withData:(NSData *)imagedata
{
    //create the URL POST Request to tumblr
    NSLog(@"createTumblrRequest method is called");
    
    NSURL *tumblrURL = [NSURL URLWithString:@"http://www.tumblr.com/api/write"];
    NSMutableURLRequest *tumblrPost = [NSMutableURLRequest requestWithURL:tumblrURL];
    [tumblrPost setHTTPMethod:@"POST"];
    
    //Add the header info
    NSString *stringBoundary = @"0xKhTmLbOuNdArY";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
    [tumblrPost addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //create the body
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //add key values from the NSDictionary object
    NSEnumerator *keys = [postKeys keyEnumerator];
    int i;
    for (i = 0; i < [postKeys count]; i++) {
        NSString *tempKey = [keys nextObject];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",tempKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@",[postKeys objectForKey:tempKey]] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //add data field and file data
    [postBody appendData:[@"Content-Disposition: form-data; name=\"data\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[NSData dataWithData:imagedata]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //add the body to the post
    [tumblrPost setHTTPBody:postBody];
    
    return tumblrPost;
}

#pragma mark - Tumblr


- (void) tumblrUploadr:(TumblrUploadr *)tu didFailWithError:(NSError *)error
{
    NSLog(@"error uploading");
}

- (void) tumblrUploadrDidSucceed:(TumblrUploadr *)tu withResponse:(NSString *)response
{
    NSLog(@"success uploading %@" ,response);
}

- (IBAction)btnLogout:(id)sender {
    UIStoryboard *storyboard = self.storyboard;
    TabBarViewController *tabBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"SplashViewController"];
    //[self presentViewController:tabBarViewController animated:YES completion:nil];
    
    UIViewController* presentingViewController = self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^
    {
        [presentingViewController presentViewController:tabBarViewController animated:YES completion:nil];
    }];
    
    [PFUser logOut];
}

@end
