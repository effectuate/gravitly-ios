//
//  SplashViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()
@property (strong, nonatomic) IBOutlet GVLabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet AMAttributedHighlightLabel *label;

@end

@implementation SplashViewController
@synthesize tagLineLabel, label;

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
    [label setDelegate:self];
    label.textColor = [UIColor lightGrayColor];
    label.hashtagTextColor = [UIColor redColor];
    
	[tagLineLabel setLabelStyle:GVRobotoCondensedRegularBlueColor size:18.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
