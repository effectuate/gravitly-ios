//
//  SettingsViewController.h
//  gravitly-ios
//
//  Created by geric on 11/11/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVBaseViewController.h"


@interface SettingsViewController :  GVBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>


@property (strong, nonatomic) IBOutlet UITableView *accountsTableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

@end
