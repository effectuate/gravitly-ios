//
//  FilterViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/28/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "FilterViewController.h"
#import <GPUImage.h>
#import "PhotoDetailsViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController {
    NSArray *filters;
}

@synthesize imageHolder;
@synthesize filterImageView;
@synthesize filterScrollView;
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
    [self setBackButton];
    [self setProceedButton];
    [self setTitle:@"Edittt"];
    filters = @[@"1977", @"Brannan", @"Gotham", @"Hefe", @"Lord Kelvin", @"Nashville", @"X-PRO II", @"yellow-red", @"aqua", @"crossprocess"];
    [self.navigationItem setTitle:@"Filter Photo"];
    
    filterImageView.contentMode = UIViewContentModeScaleAspectFit;
    filterImageView.userInteractionEnabled = YES;
    [filterImageView setImage:imageHolder];
    
    //[filterScrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 220)];
    [filterScrollView setContentSize:CGSizeMake(890, 0)];
    filterScrollView.translatesAutoresizingMaskIntoConstraints= NO;
    
    [self addBarButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBarButtonItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStylePlain target:self action:@selector(presentDetailsViewController:)];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
}


- (IBAction)presentDetailsViewController:(id *)sender {
    PhotoDetailsViewController *pdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoDetailsViewController"];
    [pdvc setImageSmall:imageHolder];
    
   // UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pdvc];
    
    [self.navigationController pushViewController:pdvc animated:YES];
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
    
    [navBar.topItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
}

- (void)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)setProceedButton {
    
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"check-big.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(proceedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    [navBar.topItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
}

- (void)proceedButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
