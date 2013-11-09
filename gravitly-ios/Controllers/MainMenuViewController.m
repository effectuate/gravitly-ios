//
//  MainMenuViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define TAG_FEED_IMAGE_VIEW 500
#define TAG_FEED_CAPTION_TEXT_VIEW 501
#define TAG_FEED_USERNAME_LABEL 502
#define TAG_FEED_DATE_CREATED_LABEL 503
#define TAG_FEED_LOCATION_LABEL 504
#define TAG_FEED_GEO_LOC_LABEL 505
#define TAG_FEED_USER_IMAGE_VIEW 506
#define TAG_FEED_ITEM_IMAGE_VIEW 601

#define REUSE_IDENTIFIER_COLLECTION_CELL @"MapCell"
#define FEED_SIZE 10
#define URL_FEED_IMAGE @"http://s3.amazonaws.com/gravitly.uploads.dev/%@"

#define TAG_GRID_VIEW 111
#define TAG_LIST_VIEW 222

#import "MainMenuViewController.h"
#import "CropPhotoViewController.h"
#import "LogInViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking.h>
#import "Feed.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "GVTableViewController.h"
#import "GVCollectionViewController.h"
#import "GVImageView.h"

@interface MainMenuViewController ()

@property (nonatomic) UIImage *capturedImaged;
@property (nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) NSMutableArray *feeds;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NMPaginator *paginator;
@property (strong, nonatomic) NSCache *cachedImages;
@property (strong, nonatomic) IBOutlet UITableView *feedTableView;

@end

@implementation MainMenuViewController

@synthesize photoFeedTableView;
@synthesize navBar;
@synthesize footerLabel;
@synthesize activityIndicator;
@synthesize collectionContainerView;
@synthesize listContainerView;

@synthesize feeds = _feeds;
@synthesize queue = _queue;
@synthesize paginator = _paginator;
@synthesize cachedImages = _cachedImages;
@synthesize feedTableView;

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
    [self setNavigationBar:navBar title:[PFUser currentUser].username];
    [self setSettingsButton];
    [self setRightBarButtons];
    
    GVCollectionViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"GVCollectionViewController"];
    [cvc setParent:[self.class description]];
    
    cvc.view.frame = self.collectionContainerView.bounds;
    [cvc willMoveToParentViewController:self];
    [self.collectionContainerView addSubview:cvc.view];
    [self addChildViewController:cvc];
    [cvc didMoveToParentViewController:self];
    
//    GVTableViewController *tbvc = [self.storyboard instantiateViewControllerWithIdentifier:@"GVTableViewController"];
//    [tbvc setParent:[self.class description]];
//    
//    tbvc.view.frame = self.listContainerView.bounds;
//    [tbvc willMoveToParentViewController:self];
//    [self.listContainerView addSubview:tbvc.view];
//    [self addChildViewController:tbvc];
//    [tbvc didMoveToParentViewController:self];
    
    [self.paginator fetchFirstPage];
    [self setupTableViewFooter];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy instatiation

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
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _cachedImages = appDelegate.feedImages;
    }
    return _cachedImages;
}

- (IBAction)btnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)btnGrabIt:(id)sender {
    NSLog(@"taking picture...");
    [self.picker takePicture];
}

- (IBAction)btnCameraRoll:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker = picker;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)btnGallery:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker = picker;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)btnLogout:(id)sender {
    LogInViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
    [self presentViewController:lvc animated:YES completion:nil];
    
    //[self presentViewController:lvc animated:YES completion:nil];
}


- (void)viewDidAppear:(BOOL)animated {
    //[super viewDidAppear:YES];
    NSLog(@"3 did appear main menu");
}

- (IBAction)cameraTab:(id)sender {
    [self.tabBarController setSelectedIndex:1];
}

-(void) finishAndUpdate {
    /*[self dismissViewControllerAnimated:YES completion:NULL];
     NSLog(@"todo.. go to cropping and filter page now..");
     CropPhotoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CropPhoto"];
     vc.imageHolder = self.capturedImaged;
     [self.navigationController pushViewController:vc animated:YES];*/
}

- (void)getLatestPhotoFromGallery {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // be sure to filter the group so you only get photos
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                ALAssetRepresentation *repr = [result defaultRepresentation];
                UIImage *img = [UIImage imageWithCGImage:[repr fullResolutionImage]];
                NSLog(@"---------------> getting latest image %@", img);
                
                *stop = YES;
            }
        }];
        *stop = NO;
    } failureBlock:^(NSError *error) {
        NSLog(@"fail *error");
    }];
}

#pragma mark - Table view delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[feedTableView dequeueReusableCellWithIdentifier:@"PhotoFeedCell"];
    
    if (cell == nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PhotoFeedCell" owner:self options:nil] objectAtIndex:0];
    }
    
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:TAG_FEED_USERNAME_LABEL];
    UITextView *captionTextView = (UITextView *)[cell viewWithTag:TAG_FEED_CAPTION_TEXT_VIEW];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:TAG_FEED_DATE_CREATED_LABEL];
    UILabel *geoLocLabel = (UILabel *)[cell viewWithTag:TAG_FEED_GEO_LOC_LABEL];
    UILabel *locationLabel = (UILabel *)[cell viewWithTag:TAG_FEED_LOCATION_LABEL];
    GVImageView *feedImageView = (GVImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
    UIImageView *userImgView = (UIImageView *)[cell viewWithTag:TAG_FEED_USER_IMAGE_VIEW];
    
    //rounded corner
    CALayer * l = [userImgView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:userImgView.frame.size.height / 2];
    
    //[imgView setImage:[UIImage imageNamed:@"placeholder.png"]];
    
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    
    NSString *tagString = @"";
    for (NSString *tag in feed.hashTags) {
        tagString = [NSString stringWithFormat:@"%@ #%@", tagString, tag];
    }
    
    [usernameLabel setText:feed.user];
    [captionTextView setText:[NSString stringWithFormat:@"%@ %@", feed.caption, tagString]];
    [geoLocLabel setText:[NSString stringWithFormat:@"%f %@, %f %@", feed.latitude, feed.latitudeRef, feed.longitude, feed.longitudeRef]];
    [locationLabel setText:feed.locationName];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateLabel setText:[dateFormatter stringFromDate:feed.dateUploaded]];
    
    NSString *imageURL = [NSString stringWithFormat:URL_FEED_IMAGE, feed.imageFileName];
    
    
    NSData *data = [self.cachedImages objectForKey:feed.imageFileName] ? [self.cachedImages objectForKey:feed.imageFileName] : nil;
    
    if (!data) {
        [feedImageView setImage:[UIImage imageNamed:@"placeholder.png"]];
        [feedImageView setUrlString:imageURL];
        [feedImageView setImageFilename:feed.imageFileName];
        [feedImageView setCachedImages:self.cachedImages];
        [feedImageView getImageFromNetwork:self.queue];
        //[feedImageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    } else {
        [feedImageView setImage:[[UIImage alloc] initWithData:data]];
    }
    
    return cell;
}

#pragma mark - Paginator methods

- (NMPaginator *)setupPaginator {
    GVPhotoFeedPaginator *pfp = [[GVPhotoFeedPaginator alloc] initWithPageSize:FEED_SIZE delegate:self];
    [pfp setParentVC:@"ScoutViewController"];
    return pfp;
}

- (void)fetchNextPage {
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
    //[photoFeedTableView reloadData];
    
    NSLog(@"paginator:didReceiveResults: - Feed Count: %i", self.feeds.count);
    
    //[photoFeedCollectionView reloadData];
    
    [feedTableView beginUpdates];
    [feedTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [feedTableView endUpdates];
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
            [self fetchNextPage];
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

#pragma mark - Nav bar button methods

- (void)setSettingsButton {
    UIButton *backButton = [self createButtonWithImageNamed:@"settings.png"];
    [backButton addTarget:self action:@selector(btnLogout:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navBar.topItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
}

- (void)setRightBarButtons {
    UIButton *listButton = [self createButtonWithImageNamed:@"list.png"];
    
    [listButton addTarget:self action:@selector(barButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [listButton setTag:TAG_LIST_VIEW];
    
    UIButton *collectionButton = [self createButtonWithImageNamed:@"collection.png"];
    [collectionButton addTarget:self action:@selector(barButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [collectionButton setTag:TAG_GRID_VIEW];
    
    UIButton *mapPinButton = [self createButtonWithImageNamed:@"map-pin.png"];
    //[mapPinButton addTarget:self action:@selector(presentMap:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *buttons = @[[[UIBarButtonItem alloc] initWithCustomView:mapPinButton], [[UIBarButtonItem alloc] initWithCustomView:listButton], [[UIBarButtonItem alloc] initWithCustomView:collectionButton]];
    
    [self.navBar.topItem setRightBarButtonItems:buttons];
}

#pragma mark - switching of view

- (IBAction)barButtonTapped:(UIButton *)barButton {
    if(barButton.tag == TAG_GRID_VIEW) {
        self.collectionContainerView.hidden = NO;
        self.listContainerView.hidden = YES;
    } else {
        self.collectionContainerView.hidden = YES;
        self.listContainerView.hidden = NO;
    }
}

@end
