//
//  CropPhotoViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/23/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CropPhotoViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *cropPhotoImageView;

@property (weak, nonatomic) UIImage *imageHolder;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *deleteMe;

- (IBAction)crop:(id)sender;


@end
