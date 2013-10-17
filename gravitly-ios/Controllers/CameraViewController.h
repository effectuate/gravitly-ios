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
#import "Metadata.h"
#import <CoreLocation/CoreLocation.h>

@interface CameraViewController : GVBaseViewController <UIImagePickerControllerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *cropperView;
@property (nonatomic) UIImage *capturedImaged;
@property (nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) IBOutlet UIImageView *capturedImageView;

@property (strong, nonatomic) IBOutlet UIImageView *cameraGridImageView;
@property (strong, nonatomic) IBOutlet UISlider *zoomSliderObject;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UIButton *hdrButton;
@property (strong, nonatomic) IBOutlet UIButton *rapidButton;
@property (strong, nonatomic) IBOutlet UIButton *delayButton;

-(IBAction)btnGallery:(id)sender;
-(IBAction)btnShutter:(id)sender;
- (IBAction)btnViewShutter:(id)sender;
- (IBAction)btnViewGallery:(id)sender;
- (IBAction)zoomSlider:(UISlider *)sender;
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;

- (IBAction)btnHDR:(id)sender;
- (IBAction)btnRapid:(id)sender;
- (IBAction)btnDelay:(id)sender;



@end
