//
//  ScoutViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/9/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define TAG_GRID_VIEW 111
#define TAG_LIST_VIEW 222
#define TAG_FEED_ITEM_IMAGE_VIEW 601

#define TAG_FEED_IMAGE_VIEW 500
#define TAG_FEED_CAPTION_TEXT_VIEW 501
#define TAG_FEED_USERNAME_LABEL 502
#define TAG_FEED_DATE_CREATED_LABEL 503
#define TAG_FEED_LOCATION_LABEL 504
#define TAG_FEED_GEO_LOC_LABEL 505
#define TAG_FEED_USER_IMAGE_VIEW 506

#define FEED_SIZE 10



#define SEARCH_BUTTON_WIDTH 50
#define NAV_BAR_WIDTH 44

#import "ScoutViewController.h"
#import "MapViewController.h"
//#import "PhotoDetailsViewController.h"
#import "Feed.h"
#import "GVCollectionViewController.h"
#import "GVTableViewController.h"

@interface ScoutViewController () {
    int startOffsetPoint;
}

@end

@implementation ScoutViewController {
    BOOL isSearchVisible;
    BOOL isNavBarVisible;
    GVCollectionViewController *cvc;
    GVTableViewController *tbvc;
    UIControl *searchControl;
    UIButton *_searchButton;
    UIButton *_tagAssistButton;
    UIButton *_closeButton;
    GVTextField *_searchTextField;
    AppDelegate *appDelegate;
    NSMutableArray *feeds;
    NSArray *searchParams;
}

@synthesize navBar;
@synthesize searchButton;
@synthesize searchView;
@synthesize paginator, photoFeedCollectionView;
@synthesize photoFeedTableView;
@synthesize activityIndicator, footerLabel;

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
    [self setSettingsButton];
    [self setRightBarButtons];
    [self setBackgroundColor:[GVColor backgroundDarkColor]];
    isSearchVisible = NO;
    isNavBarVisible = YES;
    startOffsetPoint = 0;
    
    [self setNavigationBar:navBar title:navBar.topItem.title];
    
    [self createSearchButton];
    
    feeds = [[NSMutableArray alloc] init];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.feedImages = [[NSCache alloc] init];
    
    //paginator
    self.paginator = (NMPaginator *)[self setupPaginator];
    [self.paginator fetchFirstPage];
    
    [self setupTableViewFooter];
    
    searchParams = [NSArray array];
    //[searchButton setHidden:YES];
    //[searchView setHidden:YES];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Button

- (void)createSearchButton {
    searchControl = [[UIControl alloc] initWithFrame:CGRectMake(0, -SEARCH_BUTTON_WIDTH, 320, SEARCH_BUTTON_WIDTH)];
    searchControl.backgroundColor = [GVColor buttonDarkBlueColor];
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchButton setFrame:CGRectMake((self.view.frame.size.width / 2) - (SEARCH_BUTTON_WIDTH / 2 ), 0, SEARCH_BUTTON_WIDTH, SEARCH_BUTTON_WIDTH)];
    [_searchButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [_searchButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [searchControl addSubview:_searchButton];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setFrame:CGRectMake(self.view.frame.size.width - SEARCH_BUTTON_WIDTH * 2, 0, SEARCH_BUTTON_WIDTH, SEARCH_BUTTON_WIDTH)];
    [_closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [searchControl addSubview:_closeButton];
    [_closeButton setHidden:YES];
    
    _tagAssistButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_tagAssistButton setFrame:CGRectMake(self.view.frame.size.width - SEARCH_BUTTON_WIDTH, 0, SEARCH_BUTTON_WIDTH, SEARCH_BUTTON_WIDTH)];
    [_tagAssistButton setImage:[UIImage imageNamed:@"help.png"] forState:UIControlStateNormal];
    [_tagAssistButton addTarget:self action:@selector(tagAssist:) forControlEvents:UIControlEventTouchUpInside];
    [searchControl addSubview:_tagAssistButton];
    [_tagAssistButton setHidden:YES];
    
    _searchTextField = [[GVTextField alloc] init];
    [_searchTextField setPlaceholder:@"Search"];
    [_searchTextField setFrame:CGRectMake(SEARCH_BUTTON_WIDTH, 0, 180, 40)];
//    [_searchTextField setUserInteractionEnabled:NO];
    [searchControl addSubview:_searchTextField];
    [_searchTextField setHidden:YES];
    
    [photoFeedCollectionView addSubview: searchControl];
    
    //[tbvc.photoFeedTableView.tableHeaderView addSubview: searchControl];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    CGRectSetHeight(tableView.tableHeaderView.frame, 100);
//    return searchControl;
//}

- (IBAction)tagAssist:(id)sender {
    [self performSelector:@selector(close:) withObject:sender];
    GVTagAssistViewController *tagAssist = (GVTagAssistViewController *)[[[NSBundle mainBundle] loadNibNamed:@"GVTagAssistView" owner:self options:nil] objectAtIndex:0];
    [tagAssist setDelegate:self];
    [self presentViewController:tagAssist animated:YES completion:nil];
}

- (IBAction)close:(UIButton *)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    self.view.frame = CGRectOffset(self.view.frame, 0, NAV_BAR_WIDTH);
    photoFeedTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    photoFeedCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [UIView commitAnimations];
    isSearchVisible = NO;
    isNavBarVisible = YES;
    
    [_searchButton setFrame:CGRectSetX(_searchButton.frame, (self.view.frame.size.width / 2) - (SEARCH_BUTTON_WIDTH / 2 ))];
    [_searchTextField setHidden:YES];
    [_tagAssistButton setHidden:YES];
    [_closeButton setHidden:YES];
}

- (IBAction)search:(UIButton *)sender {
    if (isNavBarVisible) {
        [UIView beginAnimations:nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        self.view.frame = CGRectOffset(self.view.frame, 0, -NAV_BAR_WIDTH);
        photoFeedTableView.frame = CGRectSetHeight(photoFeedTableView.frame, photoFeedTableView.frame.size.height+NAV_BAR_WIDTH);
        photoFeedCollectionView.frame = CGRectSetHeight(photoFeedCollectionView.frame, photoFeedCollectionView.frame.size.height+NAV_BAR_WIDTH);
        [UIView commitAnimations];
        isNavBarVisible = NO;
        [_searchButton setFrame:CGRectSetX(_searchButton.frame, 0)];
        [_searchTextField setHidden:NO];
        [_tagAssistButton setHidden:NO];
        [_closeButton setHidden:NO];
    } else {
        [Feed getFeedsWithSearchString:@"abc" withParams:searchParams from:0 to:10 :^(NSArray *objects, NSError *error) {
            for (Feed *f in objects) {
                NSLog(@"SEARCHINGGGGGG %@", f.hashTags.description);
            }
        }];
    }
}

#pragma mark - Nav bar button methods

- (void)setSettingsButton {
    GVNavButton *backButton =  [[GVNavButton alloc] init];//[UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 44, 44)];
    //[backButton setButtonColor:[UIColor darkGrayColor]];
    
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
    [mapPinButton addTarget:self action:@selector(presentMap:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *buttons = @[[[UIBarButtonItem alloc] initWithCustomView:mapPinButton], [[UIBarButtonItem alloc] initWithCustomView:listButton],
    [[UIBarButtonItem alloc] initWithCustomView:collectionButton]];
    
    [self.navBar.topItem setRightBarButtonItems:buttons];
}

- (void)setListViewButton {
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    [self.navBar.topItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
}

-(IBAction)settingsButtonTapped:(id)sender
{
    [self presentTabBarController:self];
}

-(IBAction)presentMap:(id)sender {
    NSLog(@"mapp button clicked..");
    
    MapViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];

    [self presentViewController:mvc animated:YES completion:nil];
   
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

#pragma mark - Table view delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[photoFeedTableView dequeueReusableCellWithIdentifier:@"PhotoFeedCell"];
    
    if (cell == nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PhotoFeedCell" owner:self options:nil] objectAtIndex:0];
    }
    
    //UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:TAG_FEED_USERNAME_LABEL];
    UITextView *captionTextView = (UITextView *)[cell viewWithTag:TAG_FEED_CAPTION_TEXT_VIEW];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:TAG_FEED_DATE_CREATED_LABEL];
    UILabel *geoLocLabel = (UILabel *)[cell viewWithTag:TAG_FEED_GEO_LOC_LABEL];
    UILabel *locationLabel = (UILabel *)[cell viewWithTag:TAG_FEED_LOCATION_LABEL];
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
    UIImageView *userImgView = (UIImageView *)[cell viewWithTag:TAG_FEED_USER_IMAGE_VIEW];
    
    //rounded corner
    CALayer * l = [userImgView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:userImgView.frame.size.height / 2];
    
    [imgView setImage:[UIImage imageNamed:@"placeholder.png"]];
    
    Feed *feed = [feeds objectAtIndex:indexPath.row];
    //[self getImageFromFeed:feed atIndex:indexPath];
    
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
    
    //[photoFeedTableView reloadData];
    
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
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            NSData *data = [appDelegate.feedImages objectForKey:feed.imageFileName];
            UIImage *image = [[UIImage alloc] initWithData:data];
            UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
            [imgView setImage:image];
        });
    });
    
    ////
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    
    [feeds addObjectsFromArray:results];
    //[photoFeedTableView reloadData];
    
    NSLog(@"count ng feeds %i", feeds.count);
    
    [photoFeedCollectionView reloadData];
    
    [photoFeedTableView beginUpdates];
    [photoFeedTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [photoFeedTableView endUpdates];
    [activityIndicator stopAnimating];
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

// pull down gesture

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    startOffsetPoint = scrollView.contentOffset.y;
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@">>>>>>>>> dragging");
    if (startOffsetPoint >= 0 && scrollView.contentOffset.y < -(SEARCH_BUTTON_WIDTH/2)) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        scrollView.contentInset = UIEdgeInsetsMake(SEARCH_BUTTON_WIDTH, 0, 0, 0);
        isSearchVisible = YES;
        [UIView commitAnimations];
    } else if (isSearchVisible) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [UIView commitAnimations];
        isSearchVisible = NO;
    }
}

#pragma mark - switching of view

- (IBAction)barButtonTapped:(UIButton *)barButton {
    if(barButton.tag == TAG_GRID_VIEW) {
        photoFeedCollectionView.hidden = NO;
        photoFeedTableView.hidden = YES;
        
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:0.2];
//            [UIView setAnimationDelegate:self];
//            photoFeedCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//            [UIView commitAnimations];
//
//            [searchControl removeFromSuperview];
//            isSearchVisible = NO;
//        
//            [photoFeedTableView addSubview: searchControl];
//            isSearchVisible = YES;
        
    } else {
        photoFeedCollectionView.hidden = YES;
        photoFeedTableView.hidden = NO;
        
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:0.2];
//            [UIView setAnimationDelegate:self];
//            photoFeedTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//            [UIView commitAnimations];
//        
//            [searchControl removeFromSuperview];
//        isSearchVisible = NO;
//            [photoFeedCollectionView addSubview: searchControl];
//            isSearchVisible = YES;
        
    }
}

#pragma mark - footer

- (void)setupTableViewFooter {
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    footerView.backgroundColor = [UIColor clearColor];
    GVLabel *label = [[GVLabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    //label.font = [UIFont boldSystemFontOfSize:12];
    [label setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize16];
    //label.textColor = [UIColor lightGrayColor];
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

#pragma mark - Tag Assist delegate

- (void)controllerDidDismissed:(NSArray *)additionalSearchParams {
    searchParams = additionalSearchParams;
    NSLog(@"LLLLLLLETTTTTTUCE %@",searchParams);
}

@end
