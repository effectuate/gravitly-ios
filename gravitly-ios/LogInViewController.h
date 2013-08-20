//
//  LogInViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;

@property (weak, nonatomic) IBOutlet UITextField *txtPassword;


- (IBAction)btnLogIn:(id)sender;

@end
