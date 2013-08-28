//
//  FilterViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/28/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "FilterViewController.h"
#import "UIImage+Filters.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

@synthesize imageHolder;
@synthesize filterImageView;

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
    [self.navigationItem setTitle:@"Filter Photo"];
    
    filterImageView.contentMode = UIViewContentModeScaleAspectFit;
    filterImageView.userInteractionEnabled = YES;
    [filterImageView setImage:imageHolder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)applyFilter:(UIButton *)sender {
    NSString *buttonTitle = sender.titleLabel.text;
    
    if ([buttonTitle isEqualToString:@"B&W"]) {
        filterImageView.image = [filterImageView.image saturateImage:0 withContrast:1.05];
    }
    
    if ([buttonTitle isEqualToString:@"Saturation"]) {
        filterImageView.image = [filterImageView.image saturateImage:1.7 withContrast:1];
    }
    
    /* TODO
    if ([buttonTitle isEqualToString:@"Vintage"]) {
        filterImageView.image = [filterImageView.image blendMode:@"CISoftLightBlendMode" withImageNamed:@"paper.jpg"];
    }
    */
    
    if ([buttonTitle isEqualToString:@"Curve"]) {
        filterImageView.image = [filterImageView.image curveFilter];
    }
}

- (IBAction)reset:(id)sender {
    filterImageView.image = imageHolder;
}
@end
