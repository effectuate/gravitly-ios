//
//  LogInViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVBaseViewController.h"
#import <UIKit/UIKit.h>
#import "GVButton.h"

@interface LogInViewController : GVBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIView *smaView;
@property (strong, nonatomic) IBOutlet UITableView *signUpTableView;

- (IBAction)btnLogIn:(id)sender;

@end
