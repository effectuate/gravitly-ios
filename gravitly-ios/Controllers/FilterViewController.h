//
//  FilterViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/28/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVBaseViewController.h"

@interface FilterViewController : GVBaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *filterImageView;

@property (weak, nonatomic) UIImage *imageHolder;
@property (strong, nonatomic) IBOutlet UIScrollView *filterScrollView;

- (IBAction)applyFilter:(id)sender;

- (IBAction)reset:(id)sender;

@end
