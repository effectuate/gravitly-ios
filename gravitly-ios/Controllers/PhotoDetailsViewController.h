//
//  PhotoDetailsViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 8/29/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDetailsViewController : UIViewController

@property (strong, nonatomic) UIImage *imageSmall;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)btnDone:(id)sender;

@end
