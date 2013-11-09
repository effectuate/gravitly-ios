//
//  GVMapLightBoxViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/9/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define REUSE_IDENTIFIER_COLLECTION_CELL @"MapCell"
#define FEED_SIZE 18
#define TAG_IMAGE_VIEW 700
#define URL_FEED_IMAGE @"http://s3.amazonaws.com/gravitly.uploads.dev/%@"

#import "MapLightBoxViewController.h"

@interface MapLightBoxViewController ()

@property (strong, nonatomic) NSMutableArray *feeds;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NMPaginator *paginator;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSCache *cachedImages;

@end

@implementation MapLightBoxViewController

@synthesize feeds = _feeds;
@synthesize navBar;
@synthesize paginator = _paginator;
@synthesize collectionView = _collectionView;
@synthesize queue = _queue;
@synthesize cachedImages = _cachedImages;

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
    [self setNavBar:navBar];
    
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    [self.paginator fetchFirstPage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

#pragma mark - Collection view delegates


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.feeds.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER_COLLECTION_CELL forIndexPath:indexPath];
    GVImageView *feedImageView = (GVImageView *)[cell viewWithTag:TAG_IMAGE_VIEW];
    
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
        feedImageView = [[GVImageView alloc] init];
    }
    
    NSString *imageURL = [NSString stringWithFormat:URL_FEED_IMAGE, feed.imageFileName];
    
    [feedImageView setUrlString:imageURL];
    [feedImageView setImageFilename:feed.imageFileName];
    [feedImageView setCachedImages:self.cachedImages];
//    [feedImageView setTag:888 + indexPath.row];
    [feedImageView getImageFromNetwork:self.queue];
    
    return cell;
}

- (NMPaginator *)setupPaginator {
    return [[GVPhotoFeedPaginator alloc] initWithPageSize:FEED_SIZE delegate:self];
}

- (void)fetchNextPage {
    [self.paginator fetchNextPage];
}

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSInteger i = [self.paginator.results count] - [results count];
    
    for(NSDictionary *result in results)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        i++;
    }
    
    [self.feeds addObjectsFromArray:results];
    [self.collectionView reloadData];
    
    NSLog(@"didReceiveResults >>> Feed Count: %i ", [self feeds].count);
}

#pragma mark - Scroll view delegates

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        // Ask next page only if we haven't reached last page
        if (![self.paginator reachedLastPage]) {
            [self fetchNextPage];
        }
    }
}

@end
