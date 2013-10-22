//
//  FilterViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/28/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

//TODO:standard size
#define STANDARD_SIZE 612.0f

#import "FilterViewController.h"
#import "GPUImage.h"
#import "CropPhotoViewController.h"
#import "AppDelegate.h"
#import "UIImage+Resize.h"
#import "ActivityViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController {
    NSArray *filters;
    UIImage *croppedImage;
    AppDelegate *appDelegate;
}

@synthesize imageHolder;
@synthesize filterImageView;
@synthesize filterScrollView;
@synthesize zoomScale;
@synthesize cropperScrollView;
@synthesize navBar;
@synthesize meta;
@synthesize contentOffset;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [appDelegate createFilterPlaceholders];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackButton];
    [self setProceedButton];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    filters = @[@"Normal", @"1977", @"Brannan", @"Gotham", @"Hefe", @"Lord Kelvin", @"Nashville", @"X-PRO II", @"yellow-red", @"aqua", @"crossprocess"];
    
    [self.navigationItem setTitle:@"Edit"];
    
    filterImageView.contentMode = UIViewContentModeScaleAspectFit;
    filterImageView.userInteractionEnabled = YES;
    [filterImageView setImage:imageHolder];
    
    [self fixImageZoomScale];
    
    croppedImage = [croppedImage resizeImageToSize:CGSizeMake(STANDARD_SIZE, STANDARD_SIZE)];
    
    [self setNavigationBar:navBar title:navBar.topItem.title];
    
    
    //image from link works here..
    /*
    NSURL *url = [NSURL URLWithString:@"http://s3.amazonaws.com/gravitly.uploads.dev/e97979b8-6502-4f2b-944f-8313b4bae9ac.jpeg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    filterImageView.image = image;
    */
    
    
    filterImageView.image = croppedImage;

    
    [filterScrollView setContentSize:CGSizeMake(1880, 0)];
    filterScrollView.translatesAutoresizingMaskIntoConstraints= NO;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    for (int x = 1; x < filters.count; x++) {
        UIButton *button = (UIButton *)[filterScrollView viewWithTag:x];
        NSData *data = [appDelegate.filterPlaceholders objectForKey:[filters objectAtIndex:x]];
        [button setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        
    }
    
}

#pragma mark - Image manipulations

- (void)fixImageZoomScale {
    CGSize origSize = filterImageView.frame.size;
    
    filterImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, zoomScale, zoomScale);
    [cropperScrollView setZoomScale:zoomScale];
    
    cropperScrollView.contentSize = origSize;
    [cropperScrollView setContentOffset:contentOffset];
    
    UIGraphicsBeginImageContextWithOptions(cropperScrollView.contentSize, NO, 0.0);
    {
        CGPoint savedContentOffset = cropperScrollView.contentOffset;
        CGRect savedFrame = cropperScrollView.frame;
        cropperScrollView.contentOffset = CGPointZero;
        cropperScrollView.frame = CGRectMake(0, 0, cropperScrollView.contentSize.width, cropperScrollView.contentSize.height);
        [cropperScrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
        cropperScrollView.contentOffset = savedContentOffset;
        cropperScrollView.frame = savedFrame;
    }   
    UIGraphicsEndImageContext();
    
    if (croppedImage != nil) {
        filterImageView.image = croppedImage;
        filterImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushActivityViewController {
    ActivityViewController *avc = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityViewController"];
    [avc setImageHolder:filterImageView.image];
    [avc setMeta:meta];
    [self.navigationController pushViewController:avc animated:YES];
}


- (IBAction)applyFilter:(UIButton *)sender {
    //NSString *buttonTitle = [];//sender.titleLabel.text;
    
    /*
    if ([buttonTitle isEqualToString:@"B&W"]) {
        filterImageView.image = [filterImageView.image saturateImage:0 withContrast:1.05];
    }
    */
    
    GPUImageFilter *selectedFilter;
    UIImage *filteredImage =[[UIImage alloc] init];
    NSString *filterString = [filters objectAtIndex:sender.tag];
    
    [self resetFilter];
    if (sender.tag != 0) {
        selectedFilter = [[GPUImageToneCurveFilter alloc] initWithACV:filterString];
        filteredImage = [selectedFilter imageByFilteringImage:croppedImage];
        
        filterImageView.image = filteredImage;
    }
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
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setProceedButton {
    
    UIButton *proceedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [proceedButton setImage:[UIImage imageNamed:@"check-big.png"] forState:UIControlStateNormal];
    [proceedButton addTarget:self action:@selector(proceedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [proceedButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    [navBar.topItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:proceedButton]];
}

- (void)proceedButtonTapped:(id)sender
{
    [self performSelector:@selector(pushActivityViewController) withObject:nil];
}


@end
