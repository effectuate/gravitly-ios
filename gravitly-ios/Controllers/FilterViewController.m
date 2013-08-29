//
//  FilterViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/28/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "FilterViewController.h"
#import "UIImage+Filters.h"
#import <GPUImage.h>

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
    
    /*
    if ([buttonTitle isEqualToString:@"B&W"]) {
        filterImageView.image = [filterImageView.image saturateImage:0 withContrast:1.05];
    }
    
    if ([buttonTitle isEqualToString:@"Saturation"]) {
        filterImageView.image = [filterImageView.image saturateImage:1.7 withContrast:1];
    }
    
    if ([buttonTitle isEqualToString:@"Curve"]) {
        filterImageView.image = [filterImageView.image curveFilter];
    }
    */
    
    GPUImageFilter *selectedFilter;
    
    if ([buttonTitle isEqualToString:@"Cartoon"]) {
        [self resetFilter];
        selectedFilter = [[GPUImageToonFilter alloc] init];
        UIImage *filteredImage = [selectedFilter imageByFilteringImage:filterImageView.image];
        filterImageView.image = filteredImage;
    }
    
    if ([buttonTitle isEqualToString:@"Pixel"]) {
        [self resetFilter];
        selectedFilter = [[GPUImagePixellateFilter alloc] init];
        UIImage *filteredImage = [selectedFilter imageByFilteringImage:filterImageView.image];
        filterImageView.image = filteredImage;
    }
    
    if ([buttonTitle isEqualToString:@"Distort"]) {
        [self resetFilter];
        selectedFilter = [[GPUImagePinchDistortionFilter alloc] init];
        UIImage *filteredImage = [selectedFilter imageByFilteringImage:filterImageView.image];
        filterImageView.image = filteredImage;
    }
    
}

- (IBAction)reset:(id)sender {
    [self resetFilter];
}

-(void)resetFilter {
    filterImageView.image = imageHolder;
}


@end
