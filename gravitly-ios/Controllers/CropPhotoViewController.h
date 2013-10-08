//
//  CropPhotoViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/23/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVBaseViewController.h"
#import "BFCropInterface.h"
#import "Metadata.h"

@interface CropPhotoViewController : GVBaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *cropPhotoImageView;
@property (strong, nonatomic) UIImage *imageHolder;
@property (nonatomic, strong) BFCropInterface *cropper;
@property (strong, nonatomic) Metadata *meta;


- (IBAction)undo:(id)sender;


@end
