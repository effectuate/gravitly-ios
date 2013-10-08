//
//  ActivityViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/8/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define ACTIVITY_IMAGES @[@"fishing.png", @"snow.png", @"surfing.png", @"weather.png", @"boat.png", @"fishing.png", @"snow.png", @"surfing.png", @"weather.png"]

#import "ActivityViewController.h"

@interface ActivityViewController () {
    NSArray *activities;
}

@end

@implementation ActivityViewController

@synthesize activityScrollView;
@synthesize imageHolder;
@synthesize imageView;
@synthesize navBar;

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
    }];
    [imageView setImage:imageHolder];
    [self setBackButton:navBar];
    [self setRightBarButtons:navBar];
    [self setNavigationBar:navBar title:navBar.topItem.title length:180.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)activityImages {
    return ACTIVITY_IMAGES;
}

- (void)createButtons {
    for (int i = 0; i < activities.count; i++) {
        [self createButtonForActivity:[activities objectAtIndex:i] atIndex:i];
    }
}

- (void)createButtonForActivity:(Activity *)activity atIndex:(int)idx{
    UIImage *icon = [UIImage imageNamed:[[self activityImages] objectAtIndex:idx]];
    float xPos = (idx + 1) * 8;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame: CGRectMake((100.0f * idx) + xPos, 0.0f, 100.0f, 100.0f)];
    GVLabel *label = [[GVLabel alloc] initWithFrame:CGRectMake((100.0f * idx) + xPos, 100.0f, 110.0f, 18.0f)];
    [label setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:14.0f];
    [label setText:activity.name];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    [activityScrollView setContentSize:CGSizeMake(activityScrollView.frame.size.width + 550, 0)];
    
    [button setImage:icon forState:UIControlStateNormal];
    [button setBackgroundColor:[GVColor buttonBlueColor]];
    
    //UIControl *view = [[UIControl alloc] initWithFrame:CGRectMake(13.0f, 11.0f, 100.0f, 100.0f)];
    //[view setBackgroundColor:[GVColor buttonBlueColor]];
    
    [activityScrollView addSubview:button];
    [activityScrollView addSubview:label];
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


- (void)infoButtonTapped {
    UIView *pmv = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"PhotoMetadataView" owner:self options:nil] objectAtIndex:0];
    float newXPos = (imageView.frame.size.width - pmv.frame.size.width) / 2;
    float newYPos = (imageView.frame.size.height - pmv.frame.size.height) / 2;
    [pmv setFrame:CGRectMake(newXPos, newYPos, pmv.frame.size.width, pmv.frame.size.height)];
    [imageView addSubview:pmv];
}

- (void)proceedButtonTapped {

}


@end
