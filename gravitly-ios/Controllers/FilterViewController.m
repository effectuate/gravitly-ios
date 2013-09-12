//
//  FilterViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/28/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "FilterViewController.h"
#import <GPUImage.h>
#import "CropPhotoViewController.h"
#import "PostPhotoViewController.h"
#import "AppDelegate.h"

@interface FilterViewController ()

@end

@implementation FilterViewController {
    NSArray *filters;
}

@synthesize imageHolder;
@synthesize filterImageView;
@synthesize filterScrollView;

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
    [self setBackButton];
    [self setProceedButton];

    filters = @[@"1977", @"Brannan", @"Gotham", @"Hefe", @"Lord Kelvin", @"Nashville", @"X-PRO II", @"yellow-red", @"aqua", @"crossprocess"];
    
    [self.navigationItem setTitle:@"Edit"];
    
    filterImageView.contentMode = UIViewContentModeScaleAspectFit;
    filterImageView.userInteractionEnabled = YES;
    [filterImageView setImage:imageHolder];
    
    [filterScrollView setContentSize:CGSizeMake(890, 0)];
    filterScrollView.translatesAutoresizingMaskIntoConstraints= NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)postPhotoViewController:(id *)sender {
    PostPhotoViewController *ppvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PostPhotoViewController"];
    [ppvc setImageHolder:filterImageView.image];
    
    [self.navigationController pushViewController:ppvc animated:YES];
    //[self presentViewController:ppvc animated:YES completion:nil];
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
    UIImage *filteredImage =[[UIImage alloc] init];
    NSString *filterString = [filters objectAtIndex:[buttonTitle intValue] - 1];
    
    [self resetFilter];
    selectedFilter = [[GPUImageToneCurveFilter alloc] initWithACV:filterString];
    filteredImage = [selectedFilter imageByFilteringImage:filterImageView.image];
    filterImageView.image = filteredImage;
    
}

- (IBAction)reset:(id)sender {
    [self resetFilter];
}

-(void)resetFilter {
    filterImageView.image = imageHolder;
}

#pragma mark - Nav bar button methods

- (void)setBackButton {
    
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
}

- (void)backButtonTapped:(id)sender
{
    [self presentTabBarController:self];
}


- (void)setProceedButton {
    
    UIButton *proceedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [proceedButton setImage:[UIImage imageNamed:@"check-big.png"] forState:UIControlStateNormal];
    [proceedButton addTarget:self action:@selector(proceedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [proceedButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:proceedButton]];
}

- (void)proceedButtonTapped:(id)sender
{
    [self performSelector:@selector(postPhotoViewController:) withObject:self];
}


@end
