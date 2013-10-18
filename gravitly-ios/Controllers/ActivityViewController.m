//
//  ActivityViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/8/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define BASE_URL @"http://webapi.webnuggets.cloudbees.net"
#define ENDPOINT_ENVIRONMENT @"/environment/%@/%f,%f"

#define ACTIVITY_IMAGES @[@"fishing.png", @"snow.png", @"weather.png", @"fishing.png", @"boat.png", @"surfing.png", @"surfing.png", @"surfing.png", @"weather.png"]

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
    NSDictionary *enhanceMetadata;
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
        activities = objects;
        [self createButtons];
        [self setSelectedActivity:0]; //all custom
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
    NSString *endpoint = [NSString stringWithFormat:ENDPOINT_ENVIRONMENT, selectedActivity.objectId, 45.0f,-2.0f]; //TODO:weekend geoloc
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
    
    UIButton *checkButton = [self createButtonWithImageNamed:@"check-big.png"];
    [checkButton addTarget:self action:@selector(proceedButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *buttons = @[[[UIBarButtonItem alloc] initWithCustomView:checkButton], [[UIBarButtonItem alloc] initWithCustomView:infoButton]];
    
    navbar.topItem.rightBarButtonItems = buttons;
}

- (void)setCloseButton: (UINavigationBar *)bar {
    UIButton *checkButton = [self createButtonWithImageNamed:@"close.png"];
    [checkButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    bar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:checkButton];
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
        geoLocation.text = [NSString stringWithFormat:@"%.4f N, %.4f W", meta.latitude.floatValue, meta.longitude.floatValue];
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

- (void)proceedButtonTapped {
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
    
    [self.navigationController pushViewController:ppvc animated:YES];
}

#pragma mark - JSON Helper delegates

-(void)didReceiveJSONResponse:(NSDictionary *)json {
    NSLog(@">>> Enhanced Metadata Count: %i", [[json objectForKey:selectedActivity.name] allKeys].count);
    enhanceMetadata = json;
}

-(void)didNotReceiveJSONResponse:(NSError *)error {
    NSLog(@"%@", error.debugDescription);
    enhanceMetadata = nil;
}

@end
