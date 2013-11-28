//
//  PhotoDetailsViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 8/29/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#define ALLOWED_VIEW_CONTROLLERS @[@"MainMenuViewController", @"ScoutViewController"]
#define FEED_SIZE 15

#import "PhotoDetailsViewController.h"
#import "Feed.h"

@interface PhotoDetailsViewController ()

@property (nonatomic, strong) NSString *rootViewController;
@property (strong, nonatomic) NSCache *cachedImages;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NMPaginator *paginator;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) UILabel *footerLabel;

@end

@implementation PhotoDetailsViewController

@synthesize feeds = _feeds;
@synthesize paginator = _paginator;
@synthesize photoFeedTableView = _photoFeedTableView;
@synthesize navBar;
@synthesize rootViewController = _rootViewController;
@synthesize cachedImages = _cachedImages;
@synthesize activityIndicator, footerLabel;

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

- (NSArray *)allowedViewControllers
{
    return ALLOWED_VIEW_CONTROLLERS;
}

- (NSMutableArray *)feeds {
    if (!_feeds) {
        _feeds = [[NSMutableArray alloc] init];
    }
    return _feeds;
}

- (NMPaginator *)paginator {
    if (!_paginator) {
        _paginator = [self setupPaginator];
    }
    return _paginator;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    [_queue setMaxConcurrentOperationCount:20]; // set the queue to process a max of 20 images at a time
    return _queue;
}

- (NSCache *)cachedImages
{
    if (!_cachedImages) {
        _cachedImages = [AppDelegate sharedDelegate].feedImages;
    }
    return _cachedImages;
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
    return self.feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.photoFeedTableView dequeueReusableCellWithIdentifier:@"PhotoFeedCell"];
    if (cell == nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PhotoFeedCell" owner:self options:nil] objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
        UILabel *usernameLabel = (UILabel *)[cell viewWithTag:TAG_FEED_USERNAME_LABEL];
        UITextView *captionTextView = (UITextView *)[cell viewWithTag:TAG_FEED_CAPTION_TEXT_VIEW];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:TAG_FEED_DATE_CREATED_LABEL];
        UILabel *geoLocLabel = (UILabel *)[cell viewWithTag:TAG_FEED_GEO_LOC_LABEL];
        UIImageView *userImgView = (UIImageView *)[cell viewWithTag:TAG_FEED_USER_IMAGE_VIEW];
        UIButton *locationButton = (UIButton *)[cell viewWithTag:TAG_FEED_LOCATION_BUTTON];
        UIImageView *activityIcon = (UIImageView *)[cell viewWithTag:TAG_FEED_ACTIVITY_ICON_IMAGE_VIEW];
        
        //rounded corner
        CALayer * l = [userImgView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:userImgView.frame.size.height / 2];
        
        
        Feed *feed = [self.feeds objectAtIndex:indexPath.row];
        NSString *imagePath = [NSString stringWithFormat:@"http://s3.amazonaws.com/gravitly.uploads.dev/%@", feed.imageFileName];
        
        NSString *tagString = @"";
        for (NSString *tag in feed.hashTags) {
            tagString = [NSString stringWithFormat:@"%@ #%@", tagString, tag];
        }
        
        NSData *data = [[NSData alloc] init];
        
        if ([[self allowedViewControllers] containsObject:self.rootViewController]) {
            data = [self.cachedImages objectForKey:feed.imageFileName] ? [self.cachedImages objectForKey:feed.imageFileName] : nil;
        } else {
            NSURL *url = [NSURL URLWithString:imagePath];
            data = [NSData dataWithContentsOfURL:url];
        }
        
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        NSString *icon = [NSString stringWithFormat:MINI_ICON_FORMAT, feed.activityTagName];
        [activityIcon setImage:[UIImage imageNamed:icon]];
        [imgView setImage:image];
        [usernameLabel setText:feed.user];
        [captionTextView setText:[NSString stringWithFormat:@"%@ %@", feed.caption, tagString]];
        [geoLocLabel setText:feed.elevation];
        [locationButton setTitle:feed.locationName forState:UIControlStateNormal];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
        [dateLabel setText:[dateFormatter stringFromDate:feed.dateUploaded]];
        
        NSLog(@">>>>>>> %@", [dateFormatter stringFromDate:feed.dateUploaded]);
        
        [self.photoFeedTableView reloadData];
        
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

#pragma mark - Paginator methods

- (NMPaginator *)setupPaginator {
    NMPaginator *npfp = [[GVNearestPhotoFeedPaginator alloc] initWithPageSize:FEED_SIZE delegate:self];
    return npfp;
}

- (void)fetchNextPages {
    [self.paginator fetchNextPage];
    [self.activityIndicator startAnimating];
}

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    [self updateTableViewFooter];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSInteger i = [self.paginator.results count] - [results count];
    
    for(NSDictionary *result in results)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        i++;
    }
    
    [self.feeds addObjectsFromArray:results];
    
    NSLog(@"paginator:didReceiveResults: - Feed Count: %i", self.feeds.count);
    
    [self.photoFeedTableView beginUpdates];
    [self.photoFeedTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.photoFeedTableView endUpdates];
    
    [activityIndicator stopAnimating];
}

- (void)paginatorDidReset:(id)paginator
{
    NSLog(@"ressss");
}

#pragma mark - Scroll view delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // when reaching bottom, load a new page
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        // ask next page only if we haven't reached last page
        if (![self.paginator reachedLastPage]) {
            [self fetchNextPages];
        }
    }
}

#pragma mark - footer

- (void)setupTableViewFooter {
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    footerView.backgroundColor = [UIColor clearColor];
    
    GVLabel *label = [[GVLabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [label setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize16];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.footerLabel = label;
    [footerView addSubview:label];
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.center = CGPointMake(40, 22);
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    [self.activityIndicator stopAnimating];
    self.photoFeedTableView.tableFooterView = footerView;
}

- (void)updateTableViewFooter
{
    if ([self.paginator.results count] != 0)
    {
        self.footerLabel.text = [NSString stringWithFormat:@"%d results out of %d", [self.paginator.results count], self.paginator.total];
    } else
    {
        self.footerLabel.text = @"";
    }
    
    [self.footerLabel setNeedsDisplay];
}

@end
