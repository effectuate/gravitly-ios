//
//  SettingsViewController.h
//  gravitly-ios
//
//  Created by geric on 11/11/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVBaseViewController.h"
#import "TumblrUploadr.h"


@interface SettingsViewController :  GVBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, TumblrUploadrDelegate>


@property (strong, nonatomic) IBOutlet UITableView *accountsTableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

- (IBAction)btnLogout:(id)sender;

@end
