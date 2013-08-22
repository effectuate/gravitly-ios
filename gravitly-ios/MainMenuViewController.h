//
//  MainMenuViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>



- (IBAction)btnTakePhoto:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *overlayView;
- (IBAction)btnCancel:(id)sender;

- (IBAction)btnGrabIt:(id)sender;

@end
