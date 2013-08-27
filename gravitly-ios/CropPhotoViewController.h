//
//  CropPhotoViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/23/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFCropInterface.h"

@interface CropPhotoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *cropPhotoImageView;

@property (weak, nonatomic) UIImage *imageHolder;

@property (nonatomic, strong) BFCropInterface *cropper;


- (IBAction)crop:(id)sender;


- (IBAction)undo:(id)sender;

@end
