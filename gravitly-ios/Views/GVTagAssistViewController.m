//
//  GVTagAssistViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVTagAssistViewController.h"
#import "Activity.h"
#define ACTIVITY_IMAGES @[@"weather.png", @"boat.png", @"snow.png", @"surfing.png", @"trail.png", @"wind.png", @"weather.png"]

@interface GVTagAssistViewController ()

@end

@implementation GVTagAssistViewController {
    NSArray *activities;
    NSMutableArray *activityButtons;
    Activity *selectedActivity;
}

@synthesize navBar;
@synthesize activityScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)activityImages {
    return ACTIVITY_IMAGES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setNavigationBar:navBar title:self.navBar.topItem.title];
    [Activity findAllInBackground:^(NSArray *objects, NSError *error) {
        [activities arrayByAddingObjectsFromArray:objects];
        NSLog(@">>>>>>> %@", activities);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


@end
