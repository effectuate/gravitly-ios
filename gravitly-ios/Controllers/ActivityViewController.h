//
//  ActivityViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/8/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVBaseViewController.h"
#import "Activity.h"

@interface ActivityViewController : GVBaseViewController

@property (strong, nonatomic) UIImage *imageHolder;
@property (strong, nonatomic) IBOutlet UIScrollView *activityScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;


@end
