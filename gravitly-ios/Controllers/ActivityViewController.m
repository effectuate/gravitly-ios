//
//  ActivityViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/8/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define BASE_URL @"http://webapi.webnuggets.cloudbees.net"
#define ENDPOINT_ENVIRONMENT @"/environment/%@/%f,%f"

#define ACTIVITY_IMAGES @[/*@"fishing.png", @"snow.png", */@"weather.png", @"boat.png", @"snow.png", @"surfing.png", @"trail.png", @"wind.png", @"weather.png"]

#define TAG_NAV_BAR_METADATA 101

#define TAG_DATE_CAPTURED_LABEL 400
#define TAG_GEOLOCATION_LABEL 401
#define TAG_ALTITUDE_LABEL 402
#define TAG_WIND_DIRECTION_LABEL 403

#import "ActivityViewController.h"
#import "PostPhotoViewController.h"

@interface ActivityViewController () {
    NSArray *activities;
    NSMutableArray *activityButtons;
    UINavigationBar *metadataNavBar;
    UIView *metadataView;
    Activity *selectedActivity;
    JSONHelper *jsonHelper;
    NSMutableDictionary *enhanceMetadata;
    MBProgressHUD *hud;
}

@end

@implementation ActivityViewController

@synthesize activityScrollView;
@synthesize imageHolder;
@synthesize imageView;
@synthesize navBar;
@synthesize meta;
@synthesize activityLabel;

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
    [Activity findAllInBackground:^(NSArray *objects, NSError *error) {
        NSLog(@">>>>>>>> %i", objects.count);
        activities = objects;
        [self createButtons];
    }];
    [imageView setImage:imageHolder];
    [self setBackButton:navBar];
    [self setRightBarButtons:navBar];
    [self setNavigationBar:navBar title:navBar.topItem.title length:180.0f];
    
    activityButtons = [NSMutableArray array];
    [activityLabel setLabelStyle:GVRobotoCondensedRegularBlueColor size:kgvFontSize];
    jsonHelper = [[JSONHelper alloc] init];
    [jsonHelper setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)activityImages {
    return ACTIVITY_IMAGES;
}

#pragma mark - Activity Buttons

- (void)createButtons {
    for (int i = 0; i < activities.count; i++) {
        [self createButtonForActivity:[activities objectAtIndex:i] atIndex:i];
    }
}

- (void)createButtonForActivity:(Activity *)activity atIndex:(int)idx{
    UIImage *icon = [UIImage imageNamed:[[self activityImages] objectAtIndex:idx]];
    float xPos = (idx + 1) * 11;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame: CGRectMake((100.0f * idx) + xPos, 0.0f, 100.0f, 100.0f)];
    int tag = idx;
    [button setTag:tag];
    
    //tap the button
    if (button.tag == 0) {
        //[self performSelector:@selector(activityButtonTapped:) withObject:button];
        
        //NSLog(@">>>>>>> %@", [[activities objectAtIndex:idx] objectForKey:@"objectId"]);
        //selectedActivity = [activities objectAtIndex:idx];
    }
    
    GVLabel *label = [[GVLabel alloc] initWithFrame:CGRectMake((100.0f * idx) + xPos, 100.0f, 110.0f, 18.0f)];
    [label setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:14.0f];
    [label setText:activity.name];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    [activityScrollView setContentSize:CGSizeMake(activityScrollView.frame.size.width + 574, 0)];
    
    [button setImage:icon forState:UIControlStateNormal];
    [button setBackgroundColor:[GVColor buttonGrayColor]];
    [button addTarget:self action:@selector(activityButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [activityButtons addObject:button];
    [activityScrollView addSubview:button];
    [activityScrollView addSubview:label];
    [self.view setNeedsDisplay];
}

-(IBAction)activityButtonTapped:(UIButton *)sender {
    [self setSelectedActivity:sender.tag];
    NSString *endpoint = [NSString stringWithFormat:ENDPOINT_ENVIRONMENT, selectedActivity.objectId, meta.latitude.floatValue, meta.longitude	.floatValue]; //TODO:weekend geoloc
    NSLog(@">>> %@", endpoint);
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Retrieving Metadata";
    [jsonHelper requestJSON:nil withBaseURL:BASE_URL withEndPoint:endpoint];
}

-(void)setSelectedActivity:(int)idx {
    for (UIButton *button in activityButtons) {
        if (button.tag == idx) {
            [button setBackgroundColor:[GVColor buttonBlueColor]];
            selectedActivity = [activities objectAtIndex:idx];
        } else {
            [button setBackgroundColor:[GVColor buttonGrayColor]];
        }
    }
    NSLog(@"%@ ", selectedActivity.name);
    [self.view setNeedsDisplay];
}

#pragma mark - Nav Buttons

- (void)setRightBarButtons: (UINavigationBar *) navbar {
    
    UIButton *infoButton = [self createButtonWithImageNamed:@"info.png"];
    [infoButton addTarget:self action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *proceedButton = [self createButtonWithImageNamed:@"check-big.png"];
    [proceedButton addTarget:self action:@selector(proceedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [proceedButton setFrame:CGRectMake(-1, 0, 50, 44)];
    [proceedButton setBackgroundColor:[GVColor buttonBlueColor]];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.borderColor = [GVColor backgroundDarkColor].CGColor;
    rightBorder.borderWidth = 1.0f;
    rightBorder.frame = CGRectMake(0, 0, 1, CGRectGetHeight(proceedButton.frame));
    [proceedButton.layer addSublayer:rightBorder];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:proceedButton];
    [barButton setBackgroundVerticalPositionAdjustment:-20.0f forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0f) {
        negativeSpacer.width = -16;
    } else {
        negativeSpacer.width = -6; //ios 6 below
    }
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButton, nil] animated:NO];
    
    NSArray *buttons = @[negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:proceedButton], [[UIBarButtonItem alloc] initWithCustomView:infoButton]];
    
    navbar.topItem.rightBarButtonItems = buttons;
    
}

- (void)setCloseButton: (UINavigationBar *)__navBar {
    UIButton *closeButton = [self createButtonWithImageNamed:@"close.png"];
    [closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [closeButton setFrame:CGRectMake(-1, 0, 50, 44)];
    [closeButton setBackgroundColor:[GVColor navigationBarColor]];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.borderColor = [GVColor backgroundDarkColor].CGColor;
    rightBorder.borderWidth = 1.0f;
    rightBorder.frame = CGRectMake(0, 0, 1, CGRectGetHeight(closeButton.frame));
    [closeButton.layer addSublayer:rightBorder];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    [barButton setBackgroundVerticalPositionAdjustment:-20.0f forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0f) {
        negativeSpacer.width = -16;
    } else {
        negativeSpacer.width = -6; //ios 6 below
    }
    
    [__navBar.topItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButton, nil] animated:NO];
}

- (void)infoButtonTapped {
    if (metadataView == nil) {
        metadataView = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"PhotoMetadataView" owner:self options:nil] objectAtIndex:0];
        [metadataView setAlpha:0];
        metadataNavBar = (UINavigationBar *)[metadataView viewWithTag:TAG_NAV_BAR_METADATA];
        
        UILabel *dateCaptured = (UILabel *)[metadataView viewWithTag:TAG_DATE_CAPTURED_LABEL];
        
        NSDateFormatter	*dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setDateStyle:NSDateFormatterLongStyle];
        //[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateFormat:@"MMM dd yyyy HH:mm z"];
        
        NSString *formattedDateString = [dateFormatter stringFromDate:meta.dateCaptured];
        
        
        dateCaptured.text = [NSString stringWithFormat:@"%@", formattedDateString];
        UILabel *geoLocation = (UILabel *)[metadataView viewWithTag:TAG_GEOLOCATION_LABEL];
        geoLocation.text = meta.coordinate;
        UILabel *altitude = (UILabel *)[metadataView viewWithTag:TAG_ALTITUDE_LABEL];
        altitude.text = meta.altitude;
        
        
        
        [self setCloseButton:metadataNavBar];
        [self setNavigationBar:metadataNavBar title:metadataNavBar.topItem.title];
        float newXPos = ((imageView.frame.size.width - metadataView.frame.size.width) / 2) + imageView.frame.origin.x;
        float newYPos = ((imageView.frame.size.height - metadataView.frame.size.height) / 2) + imageView.frame.origin.y;
        [metadataView setFrame:CGRectMake(newXPos, newYPos, metadataView.frame.size.width, metadataView.frame.size.height)];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.3];
        [UIView setAnimationDelegate:self];
        [metadataView setAlpha:1.0f];
        [self.view addSubview:metadataView];
        [UIView commitAnimations];
    }
}

- (void)proceedButtonTapped:(id)sender {
    [self performSelector:@selector(pushPostPhotoViewController)];
}

- (void)closeButtonTapped {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.3];
        [UIView setAnimationDelegate:self];
        [metadataView setAlpha:0];
        [UIView commitAnimations];
        dispatch_async(dispatch_get_main_queue(), ^{
            metadataView = nil;
            [metadataView removeFromSuperview];
        });
    });
}

- (void)pushPostPhotoViewController {
    PostPhotoViewController *ppvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PostPhotoViewController"];
    [ppvc setImageHolder:imageView.image];
    [ppvc setSelectedActivity:selectedActivity];    
    [ppvc setEnhancedMetadata:enhanceMetadata];
    [ppvc setBasicMetadata:meta];
    
    [self.navigationController pushViewController:ppvc animated:YES];
}

#pragma mark - JSON Helper delegates

-(void)didReceiveJSONResponse:(NSDictionary *)json {
    NSArray *allKeys = [[json objectForKey:selectedActivity.name] allKeys];
    
    NSLog(@">>> Enhanced Metadata Count: %i", allKeys.count);
    enhanceMetadata = [NSMutableDictionary dictionaryWithDictionary:[json objectForKey:selectedActivity.name]];

    
    [hud removeFromSuperview];
}

-(void)didNotReceiveJSONResponse:(NSError *)error {
    NSLog(@"%@", error.debugDescription);
    enhanceMetadata = nil;
    [hud removeFromSuperview];
}

@end
