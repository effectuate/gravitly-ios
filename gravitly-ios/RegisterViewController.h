//
//  RegisterViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/16/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *txtUserName;

@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;

- (IBAction)btnRegister:(id)sender;


@end
