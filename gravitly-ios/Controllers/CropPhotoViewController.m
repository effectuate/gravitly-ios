//
//  CropPhotoViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/23/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "CropPhotoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BFCropInterface.h"
#import "FilterViewController.h"

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
    [self.navigationItem setTitle:@"Crop Photo"];
    
    cropPhotoImageView.contentMode = UIViewContentModeScaleAspectFit;
    cropPhotoImageView.userInteractionEnabled = YES;
    [cropPhotoImageView setImage:imageHolder];
    
    // allocate crop interface with frame and image being cropped
    CGRect cropperSize = CGRectMake(0.0f, 0.0f, cropPhotoImageView.frame.size.width, cropPhotoImageView.frame.size.width);
    

    self.cropper = [[BFCropInterface alloc]initWithFrame:cropperSize andImage:imageHolder];
    
    self.cropper.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.60];
    self.cropper.borderColor = [UIColor whiteColor];
    [cropPhotoImageView addSubview:self.cropper];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Cropping functions

- (IBAction)crop:(id)sender {
    // crop image
    UIImage *croppedImage = [self.cropper getCroppedImage];
    
    // remove crop interface from superview
    [self.cropper removeFromSuperview];
    self.cropper = nil;
    // display new cropped image
    cropPhotoImageView.image = croppedImage;
}

- (IBAction)undo:(id)sender {
    cropPhotoImageView.image = imageHolder;
    if (!self.cropper) {
        self.cropper = [[BFCropInterface alloc]initWithFrame:cropPhotoImageView.bounds andImage:imageHolder];
        [cropPhotoImageView addSubview:self.cropper];
    }
}

- (IBAction)filter:(id)sender {
    FilterViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterPhoto"];
    vc.imageHolder = cropPhotoImageView.image;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
