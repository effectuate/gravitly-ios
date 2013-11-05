//
//  ScoutViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/9/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define TAG_GRID_VIEW 111
#define TAG_LIST_VIEW 222

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
}

@synthesize navBar;
@synthesize searchButton;
@synthesize searchView;
@synthesize scoutCollectionView;

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
    
    cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"GVCollectionViewController"];
    [cvc setParent:[self.class description]];
    
    
    cvc.view.frame = self.collectionContainerView.bounds;
    [cvc willMoveToParentViewController:self];
    [self.collectionContainerView addSubview:cvc.view];
    [self addChildViewController:cvc];
    [cvc didMoveToParentViewController:self];
    [cvc.photoFeedCollectionView setDelegate:self];
    
    tbvc = [self.storyboard instantiateViewControllerWithIdentifier:@"GVTableViewController"];
    [tbvc setParent:[self.class description]];
    
    tbvc.view.frame = self.listContainerView.bounds;
    [tbvc willMoveToParentViewController:self];
    [self.listContainerView addSubview:tbvc.view];
    [self addChildViewController:tbvc];
    [tbvc didMoveToParentViewController:self];
    [tbvc.photoFeedTableView setDelegate:self];
    
     [self createSearchButton];
    
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
    UIControl *viewView = [[UIControl alloc] initWithFrame:CGRectMake(0, -SEARCH_BUTTON_WIDTH, 320, SEARCH_BUTTON_WIDTH)];
    viewView.backgroundColor = [GVColor buttonDarkBlueColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 320, SEARCH_BUTTON_WIDTH)];
    [button setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [viewView addSubview:button];
    
    
    [cvc.photoFeedCollectionView addSubview: viewView];
    [tbvc.photoFeedTableView addSubview: viewView];
    
}

- (void)search {
    if (isNavBarVisible) {
        [UIView beginAnimations:nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        self.view.frame = CGRectOffset(self.view.frame, 0, -NAV_BAR_WIDTH);
        tbvc.photoFeedTableView.frame = CGRectSetHeight(tbvc.photoFeedTableView.frame, tbvc.photoFeedTableView.frame.size.height+NAV_BAR_WIDTH);
        [UIView commitAnimations];
        isNavBarVisible = NO;
    } else {
        [UIView beginAnimations:nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        self.view.frame = CGRectOffset(self.view.frame, 0, NAV_BAR_WIDTH);
        tbvc.photoFeedTableView.frame = CGRectSetHeight(tbvc.photoFeedTableView.frame, tbvc.photoFeedTableView.frame.size.height-NAV_BAR_WIDTH);
        [UIView commitAnimations];
        NSLog(@"searching");
        isNavBarVisible = YES;
    }
}


#pragma mark - Collection view controller methods


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    
    cell = [scoutCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    NSLog(@"--------------> %f", cell.frame.size.width);
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
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

#pragma mark - pull down gesture

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    startOffsetPoint = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*if (startOffsetPoint >= 0 && scrollView.contentOffset.y < -(SEARCH_BUTTON_WIDTH/2)) {
        scrollView.contentInset = UIEdgeInsetsMake(SEARCH_BUTTON_WIDTH, 0, 0, 0);
        isSearchVisible = YES;
    } else if (isSearchVisible) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [UIView commitAnimations];
        isSearchVisible = NO;
    }*/
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
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


- (void)presentPhotoDetails {
   
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
