//
//  TakePhotoViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/22/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TakePhotoViewController : UIViewController <UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

- (IBAction)takePhoto:(id)sender;


@end
