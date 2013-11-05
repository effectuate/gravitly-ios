//
//  GVCollectionViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/30/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define TAG_FEED_ITEM_IMAGE_VIEW 601

#define FEED_SIZE 10

#import "GVCollectionViewController.h"
#import "Feed.h"
#import "Activity.h"

@interface GVCollectionViewController ()

@end

@implementation GVCollectionViewController {
    AppDelegate *appDelegate;
    NSMutableArray *feeds;
}

@synthesize photoFeedCollectionView;
@synthesize paginator;
@synthesize parent;

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
    
    feeds = [[NSMutableArray alloc] init];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.feedImages = [[NSCache alloc] init];
    
    //paginator
    self.paginator = (NMPaginator *)[self setupPaginator];
    [self.paginator fetchFirstPage];

    self.collectionView = photoFeedCollectionView;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Controllers


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return feeds.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CollectionCell";
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[photoFeedCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        NSLog(@">>>>>>> %i", indexPath.row);
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    
    /*if (cell == nil) {
        NSLog(@">>>>>>>>>> %i", indexPath.row);
        cell = [photoFeedCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    }*/
    
    Feed *feed = [feeds objectAtIndex:indexPath.row];
    
    ////
    
    dispatch_queue_t queue = dispatch_queue_create("ly.gravit.DownloadingFeedImage", NULL);
    dispatch_async(queue, ^{
        
        if (![[appDelegate.feedImages objectForKey:feed.imageFileName] length]) {
            NSString *imagepath = [NSString stringWithFormat:@"http://s3.amazonaws.com/gravitly.uploads.dev/%@", feed.imageFileName];
            NSURL *url = [NSURL URLWithString:imagepath];
            NSData *data = [NSData dataWithContentsOfURL:url];
            [appDelegate.feedImages setObject:data forKey:feed.imageFileName];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // update UI
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            NSData *data = [appDelegate.feedImages objectForKey:feed.imageFileName];
            UIImage *image = [[UIImage alloc] initWithData:data];
            UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_ITEM_IMAGE_VIEW];
            [imgView setImage:image];
        });
    });
    
    ////
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(320.0f, 320.0f);
    if (!indexPath.row == 0) {
        size = CGSizeMake(100.0f, 100.0f);
        
    }
    return size;
}

#pragma mark - Paginator methods

- (NMPaginator *)setupPaginator {
    if ([parent isEqualToString:@"ScoutViewController"]) {
        GVPhotoFeedPaginator *pfp = [[GVPhotoFeedPaginator alloc] initWithPageSize:FEED_SIZE delegate:self];
        [pfp setParentVC:parent];
        return pfp;
    } else {
        return [[GVPhotoFeedPaginator alloc] initWithPageSize:FEED_SIZE delegate:self];
    }
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
    
    [feeds addObjectsFromArray:results];
    //[photoFeedTableView reloadData];
    
    NSLog(@"count ng feeds %i", feeds.count);
    
    [self.photoFeedCollectionView reloadData];
}

#pragma mark - Scroll view delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // when reaching bottom, load a new page
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        // ask next page only if we haven't reached last page
        if (![self.paginator reachedLastPage]) {
            [self fetchNextPage];
        }
    }
}


@end
