//
//  CropPhotoViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/23/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "CropPhotoViewController.h"

@interface CropPhotoViewController ()

@end

@implementation CropPhotoViewController

@synthesize cropPhotoImageView;
@synthesize imageHolder;

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
	// Do any additional setup after loading the view.
    [cropPhotoImageView setImage:imageHolder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
