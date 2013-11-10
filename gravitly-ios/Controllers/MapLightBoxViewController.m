//
//  MapLightBoxViewController
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
@property (weak, nonatomic) NMPaginator *paginator;
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
@synthesize delegate = _delegate;

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
    [self setNavigationBar:navBar title:@"0 Post" length:self.view.frame.size.width - 44];
    
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
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Paginator methods

- (GVPhotoFeedPaginator *)setupPaginator {
    GVPhotoFeedPaginator *pfp = [[GVPhotoFeedPaginator alloc] initWithPageSize:FEED_SIZE delegate:self];
    [pfp setParentVC:@"ScoutViewController"];
    return pfp;
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
    
    NSString *post = self.feeds.count <= 1? @"Post" : @"Posts";
    NSString *title = [NSString stringWithFormat:@"%i %@", self.paginator.total, post];
    [self setNavigationBar:navBar title:title length:self.view.frame.size.width - 44];
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

#pragma mark - Button actions

- (IBAction)btnClose:(id)sender {
    @try {
        //[self dismissViewControllerAnimated:YES completion:nil];
        
        if([self.delegate respondsToSelector:@selector(lightBoxDidClose)])
        {
            [self.paginator setDelegate:nil];
            [self.delegate lightBoxDidClose];
        }
    }
    @catch (NSException *exception) {
        // do nothing.
    }
}


@end
