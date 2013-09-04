//
//  LogInViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVButton.h"

@interface LogInViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;

@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@property (strong, nonatomic) IBOutlet GVButton *logInButton;
@property (strong, nonatomic) IBOutlet GVButton *signUpButton;

- (IBAction)btnLogIn:(id)sender;

@end
