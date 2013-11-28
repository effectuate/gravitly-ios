//
//  SearchResultsViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/27/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define FEED_SIZE 15

#import "SearchResultsViewController.h"
#import "Feed.h"
#import "PhotoFeedCell.h"
#import "GVImageView.h"
#import <NMPaginator.h>

@interface SearchResultsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (strong, nonatomic) NSMutableArray *feeds;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NMPaginator *paginator;
@property (strong, nonatomic) NSCache *cachedImages;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) UILabel *footerLabel;

@end

@implementation SearchResultsViewController

@synthesize feeds = _feeds;
@synthesize queue = _queue;
@synthesize paginator = _paginator;
@synthesize cachedImages = _cachedImages;
@synthesize navBar;
@synthesize activityIndicator, footerLabel;

#pragma mark - Properties

-(NSMutableArray *)feeds
{
    if (_feeds == nil) {
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

#pragma mark - self

-(void)viewDidLoad
{
    [self setNavigationBar:navBar title:self.title];
    [self setBackButton:navBar];
    [self.paginator fetchFirstPage];
    [self setupTableViewFooter];
}

- (void)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    
    NSString *tagString = @"";
    for (NSString *tag in feed.hashTags) {
        tagString = [NSString stringWithFormat:@"%@ #%@", tagString, tag];
    }
    tagString = [NSString stringWithFormat:@"%@ %@", feed.caption, tagString];
    
    // To determine the height of each cell
    float lineNumbers = ceilf(tagString.length / 50.0f);
    float height = 17 * (lineNumbers - 1);
    return 436 + height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feeds.count;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
//    UITextView *captionTextView = (UITextView *)[cell viewWithTag:TAG_FEED_CAPTION_TEXT_VIEW];
//    UIView *hashTagView = (UIView *)[cell viewWithTag:TAG_FEED_HASH_TAG_VIEW];
//    
//    for (NSString *tag in feed.hashTags) {
//        NSString *t = [NSString stringWithFormat:@"#%@", tag];
//        [self createButtonForHashTag:t inTextView:captionTextView withView:hashTagView];
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoFeedCell *cell = (PhotoFeedCell *)[self.feedTableView dequeueReusableCellWithIdentifier:@"PhotoFeedCell"];
    
    if (cell == nil) {
        cell = (PhotoFeedCell *)[[[NSBundle mainBundle] loadNibNamed:@"PhotoFeedCell" owner:self options:nil] objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:TAG_FEED_USERNAME_LABEL];
    UITextView *captionTextView = (UITextView *)[cell viewWithTag:TAG_FEED_CAPTION_TEXT_VIEW];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:TAG_FEED_DATE_CREATED_LABEL];
    UILabel *geoLocLabel = (UILabel *)[cell viewWithTag:TAG_FEED_GEO_LOC_LABEL];
    UIButton *locationButton = (UIButton *)[cell viewWithTag:TAG_FEED_LOCATION_BUTTON];
    GVImageView *feedImageView = (GVImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
    UIImageView *userImgView = (UIImageView *)[cell viewWithTag:TAG_FEED_USER_IMAGE_VIEW];
    UIImageView *activityIcon = (UIImageView *)[cell viewWithTag:TAG_FEED_ACTIVITY_ICON_IMAGE_VIEW];
    
    [locationButton addTarget:self action:@selector(filterLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    //rounded corner
    CALayer * l = [userImgView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:userImgView.frame.size.height / 2];
    
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    
    NSString *icon = [NSString stringWithFormat:MINI_ICON_FORMAT, feed.activityTagName];
    [activityIcon setImage:[UIImage imageNamed:icon]];
    [usernameLabel setText:feed.user];
    [geoLocLabel setText:feed.elevation];
    [locationButton setTitle:feed.locationName forState:UIControlStateNormal];
    
    NSDictionary *style = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:feed.captionHashTag attributes:style];
    captionTextView.attributedText = attributedString;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateLabel setText:[dateFormatter stringFromDate:feed.dateUploaded]];
    
    NSString *imageURL = [NSString stringWithFormat:URL_IMAGE, feed.imageFileName];
    
    NSData *data = [self.cachedImages objectForKey:feed.imageFileName] ? [self.cachedImages objectForKey:feed.imageFileName] : nil;
    
    if (!data) {
        [feedImageView setImage:[UIImage imageNamed:@"placeholder.png"]];
        [feedImageView setUrlString:imageURL];
        [feedImageView setImageFilename:feed.imageFileName];
        [feedImageView setCachedImages:self.cachedImages];
        [feedImageView getImageFromNetwork:self.queue];
    } else {
        [feedImageView setImage:[[UIImage alloc] initWithData:data]];
    }
    
    [cell setNeedsUpdateConstraints];
    return cell;
}

#pragma mark - Paginator methods

- (NMPaginator *)setupPaginator {
    NMPaginator *paginator = nil;
    GVSearchHashTagsPaginator *shtp = [[GVSearchHashTagsPaginator alloc] initWithPageSize:FEED_SIZE delegate:self];
    NSString *searchString = [self.title stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:@""];
    shtp.hashTags = @[searchString];
    paginator = shtp;
    return paginator;
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
    
    [self.feedTableView beginUpdates];
    [self.feedTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.feedTableView endUpdates];
    
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
    
    activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    [activityIndicator stopAnimating];
    self.feedTableView.tableFooterView = footerView;
}

- (void)updateTableViewFooter
{
    if ([self.paginator.results count] != 0)
    {
        footerLabel.text = [NSString stringWithFormat:@"%d results out of %d", [self.paginator.results count], self.paginator.total];
    } else
    {
        footerLabel.text = @"";
    }
    
    [footerLabel setNeedsDisplay];
}

-(void)dealloc
{
    [self.paginator setDelegate:nil];
}

@end
