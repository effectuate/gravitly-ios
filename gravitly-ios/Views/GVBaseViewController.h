//
//  GVBaseViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/3/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVCommons.h"
#import "GVColor.h"
#import "SocialMediaAccountsController.h"
#import "AppDelegate.h"

@interface GVBaseViewController : UIViewController

- (void)customiseTable: (UITableView *)tableView;
- (SocialMediaAccountsController *)smaView: (NSString *)label;
- (void)setBackButton;
- (UIImage *)getCapturedImage;
- (void)presentTabBarController: (id)delegate;
@end
