//
//  PhotoDetailsViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 8/29/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#define TAG_FEED_IMAGE_VIEW 500
#define TAG_FEED_CAPTION_TEXT_VIEW 501
#define TAG_FEED_USERNAME_LABEL 502
#define TAG_FEED_DATE_CREATED_LABEL 503
#define TAG_FEED_LOCATION_LABEL 505
#define TAG_FEED_USER_IMAGE_VIEW 506
#define ALLOWED_VIEW_CONTROLLERS @[@"MainMenuViewController", @"ScoutViewController"]

#import "PhotoDetailsViewController.h"
#import "Feed.h"
#import <Parse/Parse.h>

@interface PhotoDetailsViewController ()

@property (nonatomic, strong) NSString* rootViewController;
@property (strong, nonatomic) NSCache *cachedImages;

@end

@implementation PhotoDetailsViewController

@synthesize feeds;
@synthesize photoFeedTableView;
@synthesize navBar;
@synthesize rootViewController = _rootViewController;
@synthesize cachedImages = _cachedImages;

#pragma mark - Lazy Instantiation

-(NSString *)rootViewController
{
    if (!_rootViewController) {
        @try {
            UITabBarController *parent = (UITabBarController *)[self presentingViewController];
            UIViewController *viewController = [parent.viewControllers objectAtIndex:parent.selectedIndex];
            _rootViewController = NSStringFromClass([viewController class]);
        }
        @catch (NSException *exception) {
            _rootViewController = @"";
        }
    }
    return _rootViewController;
}

- (NSCache *)cachedImages
{
    if (!_cachedImages) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _cachedImages = appDelegate.feedImages;
    }
    return _cachedImages;
}

- (NSArray *)allowedViewControllers
{
    return ALLOWED_VIEW_CONTROLLERS;
}

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

#pragma mark - Table view delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [photoFeedTableView dequeueReusableCellWithIdentifier:@"PhotoFeedCell"];
    if (cell == nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PhotoFeedCell" owner:self options:nil] objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
        UILabel *usernameLabel = (UILabel *)[cell viewWithTag:TAG_FEED_USERNAME_LABEL];
        UITextView *captionTextView = (UITextView *)[cell viewWithTag:TAG_FEED_CAPTION_TEXT_VIEW];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:TAG_FEED_DATE_CREATED_LABEL];
        UIImageView *userImgView = (UIImageView *)[cell viewWithTag:TAG_FEED_USER_IMAGE_VIEW];
        UILabel *locLabel = (UILabel *)[cell viewWithTag:TAG_FEED_LOCATION_LABEL];
        
        //rounded corner
        CALayer * l = [userImgView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:userImgView.frame.size.height / 2];
        
        
        Feed *feed = [feeds objectAtIndex:indexPath.row];
        NSString *imagePath = [NSString stringWithFormat:@"http://s3.amazonaws.com/gravitly.uploads.dev/%@", feed.imageFileName];
        
        NSString *tagString = @"";
        for (NSString *tag in feed.hashTags) {
            tagString = [NSString stringWithFormat:@"%@ #%@", tagString, tag];
        }
        feed.caption = [NSString stringWithFormat:@"%@ %@", feed.caption, tagString];
        
        
        NSData *data = [[NSData alloc] init];
        
        if ([[self allowedViewControllers] containsObject:self.rootViewController]) {
            data = [self.cachedImages objectForKey:feed.imageFileName] ? [self.cachedImages objectForKey:feed.imageFileName] : nil;
            // Check here if nil
//            if (!data) {
//             [imgView setImage:[UIImage imageNamed:@"placeholder.png"]];
//             [imgView setUrlString:imagePath];
//             [imgView setImageFilename:feed.imageFileName];
//             [imgView setCachedImages:self.cachedImages];
//             [imgView getImageFromNetwork:self.queue];
//             }
        } else {
            NSURL *url = [NSURL URLWithString:imagePath];
            data = [NSData dataWithContentsOfURL:url];
        }
        
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        [imgView setImage:image];
        [usernameLabel setText:feed.user];
        [captionTextView setText:feed.caption];
        [locLabel setText:[NSString stringWithFormat:@"%f %@, %f %@", feed.latitude, feed.latitudeRef, feed.longitude, feed.longitudeRef]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateLabel setText:[dateFormatter stringFromDate:feed.dateUploaded]];
        
        NSLog(@">>>>>>> %@", [dateFormatter stringFromDate:feed.dateUploaded]);
        
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
    if ([[self allowedViewControllers] containsObject: self.rootViewController]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
