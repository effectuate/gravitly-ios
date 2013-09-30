//
//  CameraViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVBaseViewController.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CameraViewController : GVBaseViewController <UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *cropperView;
@property (nonatomic) UIImage *capturedImaged;
@property (nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) IBOutlet UIImageView *capturedImageView;

@property (strong, nonatomic) IBOutlet UIImageView *cameraGridImageView;
@property (strong, nonatomic) IBOutlet UISlider *zoomSliderObject;

-(IBAction)btnGallery:(id)sender;
-(IBAction)btnShutter:(id)sender;
- (IBAction)btnViewShutter:(id)sender;
- (IBAction)btnViewGallery:(id)sender;
- (IBAction)zoomSlider:(UISlider *)sender;
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;

@end
