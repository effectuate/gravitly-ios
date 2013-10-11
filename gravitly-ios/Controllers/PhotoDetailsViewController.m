//
//  PhotoDetailsViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 8/29/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#define TAG_FEED_IMAGE_VIEW 500
#define TAG_FEED_CAPTION_LABEL 501
#define TAG_FEED_USERNAME_LABEL 502

#import "PhotoDetailsViewController.h"
#import "Feed.h"
#import <Parse/Parse.h>

@interface PhotoDetailsViewController ()

@end

@implementation PhotoDetailsViewController

@synthesize feeds;
@synthesize photoFeedTableView;
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
    [self setNavigationBar:navBar title:navBar.topItem.title];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [photoFeedTableView dequeueReusableCellWithIdentifier:@"PhotoFeedCell"];
    if (cell == nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PhotoFeedCell" owner:self options:nil] objectAtIndex:0];
        UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
        UILabel *usernameLabel = (UILabel *)[cell viewWithTag:TAG_FEED_USERNAME_LABEL];
        UILabel *captionLabel = (UILabel *)[cell viewWithTag:TAG_FEED_CAPTION_LABEL];
        
        Feed *feed = [feeds objectAtIndex:indexPath.row];
        NSString *imagepath = [NSString stringWithFormat:@"http://s3.amazonaws.com/gravitly.uploads.dev/%@", feed.imageFileName];
        
        NSString *tagString = @"";
        for (NSString *tag in feed.hashTags) {
            tagString = [NSString stringWithFormat:@"%@ #%@", tagString, tag];
        }
        feed.caption = [NSString stringWithFormat:@"%@ %@", feed.caption, tagString];
        
        NSURL *url = [NSURL URLWithString:imagepath];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:data];
        [imgView setImage:image];
        [usernameLabel setText:feed.user];
        [captionLabel setText:feed.caption];
        [photoFeedTableView reloadData];
        
    }
    return cell;
}

#pragma mark - Back and Proceed button methods

- (void)setBackButton
{
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    navBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)backButtonTapped:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
