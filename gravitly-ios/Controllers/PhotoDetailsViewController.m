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
#import "SearchResultsViewController.h"
#import "PhotoFeedCell.h"
#import "MapViewController.h"
#import "SocialSharingViewController.h"

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
    
    [self setBackButton:navBar];
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
        UIButton *flagButton = (UIButton *)[cell viewWithTag:TAG_FEED_FLAG_BUTTON];
        UIButton *shareButton = (UIButton *)[cell viewWithTag:TAG_FEED_SHARE_BUTTON];
        
        [flagButton addTarget:self action:@selector(flag) forControlEvents:UIControlEventTouchUpInside];
        [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        
        [locationButton addTarget:self action:@selector(locationButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    CGSize size = CGSizeMake(320.0f, 103.0f);
    CGSize textFieldSize = [feed.captionHashTag sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:12.0f] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    return 420.0f+textFieldSize.height+2.0f;
}


#pragma mark - Back and Proceed button methods

/*- (void)setBackButton
{
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    navBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}*/

- (UIBarButtonItem *)setBackButton:(UINavigationBar *)__navBar
{
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(-1, 0, 50, 44)];
    [backButton setBackgroundColor:[GVColor navigationBarColor]];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.borderColor = [GVColor backgroundDarkColor].CGColor;
    rightBorder.borderWidth = 1.0f;
    rightBorder.frame = CGRectMake(CGRectGetWidth(backButton.frame), 0, 1, CGRectGetHeight(backButton.frame));
    [backButton.layer addSublayer:rightBorder];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [barButton setBackgroundVerticalPositionAdjustment:-20.0f forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0f) {
        negativeSpacer.width = -16;
    } else {
        negativeSpacer.width = -6; //ios 6 below
    }
    
    [__navBar.topItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButton, nil] animated:NO];
    
    //[navBar.topItem setLeftBarButtonItem:barButton];
    return barButton;
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

- (void)hashTagButtonDidClick: (UIButton *)button
{
    SearchResultsViewController *srvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultsViewController"];
    srvc.searchPurpose = GVSearchHashTag;
    srvc.title = button.titleLabel.text;
    [self presentViewController:srvc animated:YES completion:nil];
    NSLog(@">>>>>>>>> %@", button.titleLabel.text);
}

#pragma mark - Search near location

- (void)locationButtonDidClick: (UIButton *)button
{
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.photoFeedTableView];
    NSIndexPath *indexPath = [self.photoFeedTableView indexPathForRowAtPoint:buttonPosition];
    Feed *selectedFeed = (Feed *)[self.feeds objectAtIndex:indexPath.row];
    
    MapViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [mvc setSelectedFeed:selectedFeed];
    [self presentViewController:mvc animated:YES completion:nil];
}

#pragma mark - Flag and share

-(void)share:(UIButton *)button
{
    UITableViewCell *cell = (UITableViewCell *)button.superview.superview;
    GVImageView *feedImageView = (GVImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
    
    NSIndexPath *indexPath = [self.photoFeedTableView indexPathForCell:cell];
    
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    
    SocialSharingViewController *sharing = (SocialSharingViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SocialSharingViewController"];
    [sharing setToShareImage:feedImageView.image];
    [sharing setToShareLink:[NSString stringWithFormat:URL_IMAGE, feed.imageFileName]];
    
    [self presentViewController:sharing animated:YES completion:nil];
}


@end
