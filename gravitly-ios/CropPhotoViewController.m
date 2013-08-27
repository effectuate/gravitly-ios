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
    cropPhotoImageView.frame = CGRectMake(20, 20, 280, 360);
    //self.originalImage = [UIImage imageNamed:@"dumbo.jpg"];
    //cropPhotoImageView.image = self.originalImage;
    [cropPhotoImageView setImage:imageHolder];
    
    // allocate crop interface with frame and image being cropped
    self.cropper = [[BFCropInterface alloc]initWithFrame:cropPhotoImageView.bounds andImage:imageHolder];
    
    // this is the default color even if you don't set it
    self.cropper.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.60];
    // white is the default border color.
    self.cropper.borderColor = [UIColor whiteColor];
    // add interface to superview. here we are covering the main image view.
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

@end
