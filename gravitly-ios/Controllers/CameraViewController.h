//
//  CameraViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVBaseViewController.h"
#import <UIKit/UIKit.h>

@interface CameraViewController : GVBaseViewController <UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *cropperView;
@property (nonatomic) UIImage *capturedImaged;
@property (nonatomic) UIImagePickerController *picker;

-(IBAction)btnGallery:(id)sender;
-(IBAction)btnShutter:(id)sender;
- (IBAction)btnViewShutter:(id)sender;
- (IBAction)btnViewGallery:(id)sender;

@end
