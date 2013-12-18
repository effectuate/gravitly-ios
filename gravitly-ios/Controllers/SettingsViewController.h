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


//- (IBAction)btnCancel:(id)sender;
//
//- (IBAction)btnTwitter:(id)sender;
//
//- (IBAction)btnUnlinkTwitter:(id)sender;
//
//- (IBAction)btnFacebook:(id)sender;
//
//- (IBAction)btnUnlinkFacebook:(id)sender;

@end
