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
#import "GVTagAssistViewController.h"

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
}

@synthesize navBar;
@synthesize searchButton;
@synthesize searchView;

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
    //[cvc.photoFeedCollectionView setDelegate:self];
    
    tbvc = [self.storyboard instantiateViewControllerWithIdentifier:@"GVTableViewController"];
    [tbvc setParent:[self.class description]];
    
    tbvc.view.frame = self.listContainerView.bounds;
    [tbvc willMoveToParentViewController:self];
    [self.listContainerView addSubview:tbvc.view];
    [self addChildViewController:tbvc];
    [tbvc didMoveToParentViewController:self];
    //[tbvc.photoFeedTableView setDelegate:self];
    
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
    
    [cvc.photoFeedCollectionView addSubview: searchControl];
    [tbvc.photoFeedTableView addSubview: searchControl];
    //[tbvc.photoFeedTableView.tableHeaderView addSubview: searchControl];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    CGRectSetHeight(tableView.tableHeaderView.frame, 100);
//    return searchControl;
//}

- (IBAction)tagAssist:(id)sender {
    [self performSelector:@selector(close:) withObject:sender];
    GVTagAssistViewController *tagAssist = (GVTagAssistViewController *)[[[NSBundle mainBundle] loadNibNamed:@"GVTagAssistView" owner:self options:nil] objectAtIndex:0];
    [self presentViewController:tagAssist animated:YES completion:nil];
}

- (IBAction)close:(UIButton *)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    self.view.frame = CGRectOffset(self.view.frame, 0, NAV_BAR_WIDTH);
    tbvc.photoFeedTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
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
        tbvc.photoFeedTableView.frame = CGRectSetHeight(tbvc.photoFeedTableView.frame, tbvc.photoFeedTableView.frame.size.height+NAV_BAR_WIDTH);
        cvc.photoFeedCollectionView.frame = CGRectSetHeight(cvc.photoFeedCollectionView.frame, cvc.photoFeedCollectionView.frame.size.height+NAV_BAR_WIDTH);
        [UIView commitAnimations];
        isNavBarVisible = NO;
        [_searchButton setFrame:CGRectSetX(_searchButton.frame, 0)];
        [_searchTextField setHidden:NO];
        [_tagAssistButton setHidden:NO];
        [_closeButton setHidden:NO];
    } else {
        NSLog(@"SEARCHINGGGGGG");
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

#pragma mark - pull down gesture

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
        self.collectionContainerView.hidden = NO;
        self.listContainerView.hidden = YES;
    } else {
        self.collectionContainerView.hidden = YES;
        self.listContainerView.hidden = NO;
    }
}

@end
