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

- (SocialMediaAccountsController *)smaView: (NSString *)label;
- (UIBarButtonItem *)setBackButton:(UINavigationBar *)navBar;
- (UIImage *)getCapturedImage;
- (UIButton *)createButtonWithImageNamed: (NSString *)image;

- (void)customiseTable: (UITableView *)tableView;
- (void)presentTabBarController: (id)delegate;
- (void)setBackgroundColor:(UIColor *)color;
- (void)setNavigationBar:(UINavigationBar *)navBar title:(NSString *)title;

@end
