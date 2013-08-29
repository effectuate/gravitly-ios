//
//  MainMenuViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *cropperView;


- (IBAction)btnTakePhoto:(id)sender;

- (IBAction)btnCancel:(id)sender;

- (IBAction)btnGrabIt:(id)sender;

- (IBAction)btnCameraRoll:(id)sender;
- (IBAction)btnGallery:(id)sender;
- (IBAction)btnLogout:(id)sender;


@end
