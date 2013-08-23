//
//  CropPhotoViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/23/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "CropPhotoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CropPhotoViewController ()

@end

@implementation CropPhotoViewController

@synthesize cropPhotoImageView;
@synthesize imageHolder;
@synthesize imageScrollView;
@synthesize deleteMe;

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
    [self.navigationItem setTitle:@"Crop Photo"];
    [cropPhotoImageView setImage:imageHolder];
    [self setUpScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scrolling functions

- (void)setUpScrollView {
    [self.imageScrollView setMinimumZoomScale:1.0f];
    [self.imageScrollView setMaximumZoomScale:6.0f];
    [self.imageScrollView setContentSize:CGSizeMake(960, 960)];
    [self.imageScrollView setDelegate:self];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.cropPhotoImageView;
}

#pragma mark - Cropping functions

- (IBAction)crop:(id)sender {
    
    
    UIGraphicsBeginImageContext(self.imageScrollView.bounds.size);
    [self.imageScrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [deleteMe setImage:viewImage];
    
    NSLog(@"--------> cropped %@ height %f w %f", viewImage, imageScrollView.bounds.size.height, imageScrollView.bounds.size.width );
}


- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
