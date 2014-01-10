//
//  ScoutViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/9/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#define FEED_SIZE 15

#define SEARCH_BUTTON_WIDTH 50
#define NAV_BAR_WIDTH 44

#import "ScoutViewController.h"
#import "MapViewController.h"
//#import "PhotoDetailsViewController.h"
#import "Feed.h"
#import "UIImage+Resize.h"
#import "GVImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "PhotoFeedCell.h"
#import "SearchResultsViewController.h"
#import "SettingsViewController.h"
#import "SocialSharingViewController.h"

@interface ScoutViewController () {
    int startOffsetPoint;
}
@property (strong, nonatomic) NSCache *cachedImages;
@property (strong, nonatomic) IBOutlet UITableView *feedTableView;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableArray *feeds;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation ScoutViewController {
    BOOL isSearchVisible;
    BOOL isNavBarVisible;
    UIControl *searchControl;
    UIButton *_searchButton;
    UIButton *_tagAssistButton;
    UIButton *_closeButton;
    GVTextField *_searchTextField;
    UIScrollView *_wrapper;
    NSArray *searchParams;
}

@synthesize navBar;
@synthesize searchButton;
@synthesize searchView;
@synthesize paginator, photoFeedCollectionView;
@synthesize photoFeedTableView;
@synthesize activityIndicator, footerLabel;
@synthesize cachedImages = _cachedImages;
@synthesize feeds = _feeds;
@synthesize selectedIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Lazy instantiation

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

- (NSMutableArray *)feeds {
    if (!_feeds) {
        _feeds = [[NSMutableArray alloc] init];
    }
    return _feeds;
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
    
    if (IS_IPHONE_5) {
        NSLog(@"IPHONE 5 TEST");
    }
    
    [self createSearchButton];
    
    //paginator
    self.paginator = [self setupPaginator];
    [self.paginator fetchFirstPage];
    
    [self setupTableViewFooter];
    
    searchParams = [NSArray array];
    selectedIndexPath = [[NSIndexPath alloc] init];
    [photoFeedTableView setDelegate:self];
    [photoFeedTableView setDataSource:self];
    
    //initial state
    UIButton *b = (UIButton *)[navBar viewWithTag:TAG_GRID_VIEW];
    [b setTintColor:[GVColor buttonBlueColor]];
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
    [_searchTextField setDefaultFontStyle];
    [_searchTextField setPlaceholder:@"Search"];
    [_searchTextField setFrame:CGRectMake(0, 3, 180, 40)];
    
    _wrapper = [[UIScrollView alloc] initWithFrame:CGRectMake(SEARCH_BUTTON_WIDTH, 3, 180, 40)];
    _wrapper.scrollEnabled = NO;
    [_wrapper addSubview: _searchTextField];
    
    [searchControl addSubview:_wrapper];
    [_wrapper setHidden:YES];
    [_searchTextField setHidden:YES];
    [_searchTextField setDelegate:self];
    
    [photoFeedCollectionView addSubview: searchControl];
}

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
    [_wrapper setHidden:YES];
    [_tagAssistButton setHidden:YES];
    [_closeButton setHidden:YES];
    [_searchTextField resignFirstResponder];
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
        [_wrapper setHidden:NO];
        [_tagAssistButton setHidden:NO];
        [_closeButton setHidden:NO];
    } else {
        [self.paginator reset];
        [self.paginator setParentVC:@"Search"];
        [self.paginator setHashTags:searchParams];
        [self.paginator setSearchString:_searchTextField.text];
        [self fetchNextPage];
        
        /*[Feed getFeedsWithSearchString:_searchTextField.text withParams:searchParams from:0 to:10 :^(NSArray *objects, NSError *error) {
            for (Feed *f in objects) {
                //NSLog(@"SEARCHINGGGGGG %@", f.hashTags.description);
            }
            //NSLog(@"feeds found %i", objects.count);
//            @"%i photo(s) with % \"@ \"
            NSString *searchResult = [NSString stringWithFormat:@"%i photo(s) with \"%@\"", objects.count, _searchTextField.text];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:searchResult delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }];*/
    }
}

#pragma mark - Nav bar button methods

- (void)setSettingsButton {
    UIButton *leftBarButton = [self createButtonWithImageNamed:@"settings.png"];
        [leftBarButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    [leftBarButton setFrame:CGRectMake(-1, 0, 50, 44)];
    [leftBarButton setBackgroundColor:[GVColor navigationBarColor]];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.borderColor = [GVColor backgroundDarkColor].CGColor;
    rightBorder.borderWidth = 1.0f;
    rightBorder.frame = CGRectMake(CGRectGetWidth(leftBarButton.frame), 0, 1, CGRectGetHeight(leftBarButton.frame));
    [leftBarButton.layer addSublayer:rightBorder];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    [barButton setBackgroundVerticalPositionAdjustment:-20.0f forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0f) {
        negativeSpacer.width = -16;
    } else {
        negativeSpacer.width = -6; //ios 6 below
    }
    
    [self.navBar.topItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButton, nil] animated:NO];
    
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
    //[self presentTabBarController:self];
    SettingsViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self presentViewController:svc animated:YES completion:nil];
}

-(IBAction)presentMap:(id)sender {
    NSLog(@"mapp button clicked..");
    
    MapViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [self presentViewController:mvc animated:YES completion:nil];
}

#pragma mark - Collection View Controllers

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.feeds.count;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_ITEM_IMAGE_VIEW];
//    [imgView setImage:[UIImage imageNamed:@"placeholder.png"]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CollectionCell";
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[photoFeedCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    GVImageView *feedImageView = (GVImageView *)[cell viewWithTag:TAG_FEED_ITEM_IMAGE_VIEW];
    
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [backgroundView setBackgroundColor:[GVColor redColor]];
    cell.selectedBackgroundView = backgroundView;
    //cell.selectedBackgroundView = //[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-selected.png"]];
    
    if (self.selectedIndexPath != nil && [indexPath compare:self.selectedIndexPath] == NSOrderedSame) {
        [feedImageView.layer setBorderColor: [[GVColor buttonBlueColor] CGColor]];
        [feedImageView.layer setBorderWidth: 2.0];
    } else {
        [feedImageView.layer setBorderColor: nil];
        [feedImageView.layer setBorderWidth: 0.0];
    }
    
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    
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
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100.0f, 100.0f);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedIndexPath = indexPath;
    //[collectionView reloadItemsAtIndexPaths:@[indexPath]];
    [collectionView reloadData];
    
    [self presentPhotoDetailsViewControllerWithIndex:indexPath.row];
}

#pragma mark - Table view delegates

-(void)tableView:(UITableView *)tableView willDisplayCell:(PhotoFeedCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    UITextView *captionTextView = (UITextView *)[cell viewWithTag:TAG_FEED_CAPTION_TEXT_VIEW];
    UIView *hashTagView = (UIView *)[cell viewWithTag:TAG_FEED_HASH_TAG_VIEW];
    
    NSMutableArray *substrings = [NSMutableArray new];
    NSScanner *scanner = [NSScanner scannerWithString:feed.captionHashTag];
    [scanner scanUpToString:@"#" intoString:nil];
    
    NSScanner *scanner2 = [NSScanner scannerWithString:feed.captionHashTag];
    [scanner2 scanUpToString:@"@" intoString:nil];
    
    while(![scanner isAtEnd]) {
        NSString *substring = nil;
        [scanner scanString:@"#" intoString:nil];
        [scanner2 scanString:@"@" intoString:nil];  
        
        if([scanner scanUpToString:@" " intoString:&substring]) {
            [substrings addObject:[NSString stringWithFormat:@"#%@", substring]];
        }
        if([scanner2 scanUpToString:@" " intoString:&substring]) {
            [substrings addObject:[NSString stringWithFormat:@"@%@", substring]];
        }
        [scanner scanUpToString:@"#" intoString:nil];
        [scanner2 scanUpToString:@"@" intoString:nil];
    }
    
    for (NSString *substring in substrings) {
        [self createButtonForHashTag:substring inTextView:captionTextView withView:hashTagView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[photoFeedTableView dequeueReusableCellWithIdentifier:@"PhotoFeedCell"];
    
    if (cell == nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PhotoFeedCell" owner:self options:nil] objectAtIndex:0];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; 
    
    //UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:TAG_FEED_USERNAME_LABEL];
    UITextView *captionTextView = (UITextView *)[cell viewWithTag:TAG_FEED_CAPTION_TEXT_VIEW];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:TAG_FEED_DATE_CREATED_LABEL];
    UILabel *geoLocLabel = (UILabel *)[cell viewWithTag:TAG_FEED_GEO_LOC_LABEL];
    UIButton *locationButton = (UIButton *)[cell viewWithTag:TAG_FEED_LOCATION_BUTTON];
    GVImageView *feedImageView = (GVImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
    UIImageView *userImgView = (UIImageView *)[cell viewWithTag:TAG_FEED_USER_IMAGE_VIEW];
    UIImageView *activityIcon = (UIImageView *)[cell viewWithTag:TAG_FEED_ACTIVITY_ICON_IMAGE_VIEW];
    UIButton *flagButton = (UIButton *)[cell viewWithTag:TAG_FEED_FLAG_BUTTON];
    UIButton *shareButton = (UIButton *)[cell viewWithTag:TAG_FEED_SHARE_BUTTON];
    
    [flagButton addTarget:self action:@selector(flag:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [locationButton addTarget:self action:@selector(locationButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];

    
    //rounded corner
    CALayer * l = [userImgView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:userImgView.frame.size.height / 2];
    
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    //[self getImageFromFeed:feed atIndex:indexPath];
    
    if (feed.flag) {
        [flagButton setBackgroundColor:[GVColor buttonBlueColor]];
    } else {
        [flagButton setBackgroundColor:[GVColor buttonDarkGrayColor]];
    }
    
#warning Balbonic
    flagButton.tag = indexPath.row;
    shareButton.tag = indexPath.row;
    
    NSString *tagString = @"";
    for (NSString *tag in feed.hashTags) {
        tagString = [NSString stringWithFormat:@"%@ #%@", tagString, tag];
    }
    
    NSString *icon = [NSString stringWithFormat:MINI_ICON_FORMAT, feed.activityTagName];
    [activityIcon setImage:[UIImage imageNamed:icon]];
    [usernameLabel setText:feed.user];
    [captionTextView setText:[NSString stringWithFormat:@"%@ %@", feed.caption, tagString]];
    [geoLocLabel setText:feed.elevation];
    [locationButton setTitle:feed.locationName forState:UIControlStateNormal];
    
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
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self presentPhotoDetailsViewControllerWithIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    CGSize size = CGSizeMake(320.0f, 103.0f);
    CGSize textFieldSize = [feed.captionHashTag sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:12.0f] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    return 420.0f+textFieldSize.height+2.0f;
}

#pragma mark - Photo details method

- (void)presentPhotoDetailsViewControllerWithIndex: (int)row {
    PhotoDetailsViewController *pdvc = (PhotoDetailsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PhotoDetailsViewController"];
    
    Feed *latestFeed = (Feed *)[self.feeds objectAtIndex:row];
    [pdvc setFeeds:@[latestFeed]];
    [self presentViewController:pdvc animated:YES completion:nil];
    //[self.navigationController pushViewController:pdvc animated:YES];
}

#pragma mark - Paginator methods

- (GVPhotoFeedPaginator *)setupPaginator {
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
    
    NSLog(@"paginator:didReceiveResults: %i", self.feeds.count);
    
    [photoFeedCollectionView reloadData];
    
    [photoFeedTableView beginUpdates];
    [photoFeedTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [photoFeedTableView endUpdates];
    [activityIndicator stopAnimating];
}

- (void)paginatorDidReset:(id)paginator {
    NSLog(@"ressss");	
}

#pragma mark - Scroll view delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"%f %f", scrollView.contentOffset.y, scrollView.contentSize.height - scrollView.bounds.size.height);
    // when reaching bottom, load a new page
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height)
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
        UIButton *b = (UIButton *)[navBar viewWithTag:TAG_LIST_VIEW];
        [b setTintColor:[GVColor whiteColor]];
        [barButton setTintColor:[GVColor buttonBlueColor]];
    } else {
        photoFeedCollectionView.hidden = YES;
        photoFeedTableView.hidden = NO;
        UIButton *b = (UIButton *)[navBar viewWithTag:TAG_GRID_VIEW];
        [b setTintColor:[GVColor whiteColor]];
        [barButton setTintColor:[GVColor buttonBlueColor]];
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


#pragma mark - Textfield delegates

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Clickable Hashtag

- (void)createButtonForHashTag:(NSString *)hashtag inTextView:(UITextView *)textView withView:(UIView *)view
{
    NSMutableAttributedString *attrString = textView.attributedText.mutableCopy;
    NSUInteger count = 0;
    NSUInteger length = [textView.attributedText.string length];
    NSRange range = NSMakeRange(0, length);
    
    while(range.location != NSNotFound)
    {
        range = [attrString.string rangeOfString:hashtag options:0 range:range];
        if(range.location != NSNotFound) {
            
            [attrString addAttribute:NSForegroundColorAttributeName value:[GVColor buttonBlueColor] range:range];
            [textView setAttributedText:attrString];
            
            UITextPosition *Pos2 = [textView positionFromPosition: textView.beginningOfDocument offset: range.location];
            UITextPosition *Pos1 = [textView positionFromPosition: textView.beginningOfDocument offset: range.location + range.length];
            
            UITextRange *textRange = [textView textRangeFromPosition:Pos1 toPosition:Pos2];
            
            CGRect rect = [textView firstRectForRange:(UITextRange *)textRange ];
            
            //NSLog(@"%f, %f", rect.origin.x, rect.origin.y);
            
            UIButton *button = [[UIButton alloc] initWithFrame:rect];
            button.tag = 99;
            //button.backgroundColor = [UIColor greenColor];
            button.titleLabel.text = hashtag;
            [view addSubview:button];
            
            [button addTarget:self action:@selector(hashTagButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            count++;
        }
    }
}

//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:@"Flagged!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
//                [alert show];

#pragma mark - Flag and Share buttons

-(void)flag:(UIButton *)button
{
    PhotoFeedCell *cell = (PhotoFeedCell *)button.superview.superview.superview;
    GVImageView *feedImageView = (GVImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
    
#warning Balbonic
    //NSIndexPath *indexPath = [self.feedTableView indexPathForCell:cell];
    
    Feed *feed = [self.feeds objectAtIndex:button.tag];
    
    if (!feed.flag) {
        button.enabled = NO;
        [feed flagFeedInBackground:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                button.enabled = YES;
                NSLog(@"<<<<<<<<<<< FLAGGED %@", feed.objectId);
            }
        }];
        [feed setFlag:YES];
        [button setBackgroundColor:[GVColor buttonBlueColor]];
    } else {
        button.enabled = NO;
        [feed unflagFeedInBackground:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                button.enabled = YES;
                NSLog(@"<<<<<<<<<<< UNFLAGGED %@", feed.objectId);
            }
        }];
        [feed setFlag:NO];
        [button setBackgroundColor:[GVColor buttonDarkGrayColor]];
    }
    
}

-(void)share:(UIButton *)button
{
    UITableViewCell *cell = (UITableViewCell *)button.superview.superview.superview;
    GVImageView *feedImageView = (GVImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
    
#warning Balbonic
    //NSIndexPath *indexPath = [self.feedTableView indexPathForCell:cell];
    
    Feed *feed = [self.feeds objectAtIndex:button.tag];
    
    SocialSharingViewController *sharing = (SocialSharingViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SocialSharingViewController"];
    [sharing setToShareImage:feedImageView.image];
    [sharing setToShareLink:[NSString stringWithFormat:URL_IMAGE, feed.imageFileName]];
    
    [self presentViewController:sharing animated:YES completion:nil];
    
}


#pragma mark - Search functions

- (void)hashTagButtonDidClick: (UIButton *)button
{
    SearchResultsViewController *srvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultsViewController"];
    srvc.searchPurpose = GVSearchHashTag;
    srvc.title = button.titleLabel.text;
    [self presentViewController:srvc animated:YES completion:nil];
    NSLog(@">>>>>>>>> %@", button.titleLabel.text);
}

- (void)locationButtonDidClick: (UIButton *)button
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    [self.view addSubview:hud];
    
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.photoFeedTableView];
    NSIndexPath *indexPath = [self.photoFeedTableView indexPathForRowAtPoint:buttonPosition];
    Feed *selectedFeed = (Feed *)[self.feeds objectAtIndex:indexPath.row];
    
    MapViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [mvc setSelectedFeed:selectedFeed];
    [self presentViewController:mvc animated:YES completion:nil];
}


@end
