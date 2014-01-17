//
//  RegisterViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/16/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "RegisterViewController.h"
#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "GVTableCell.h"
#import "NSString+MD5.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController {
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    UITextField *firstnameTextField;
    UITextField *lastnameTextField;
    UITextField *emailTextField;
    UITextField *phoneNumberTextField;
    BOOL isAgreeChecked;
}

@synthesize txtUserName;
@synthesize txtPassword;
@synthesize txtEmail;
@synthesize signUpTableView;
@synthesize signUpButton;
@synthesize socialMediaAccountsView;
@synthesize navBar;
@synthesize checkButton;
@synthesize termsButton;
@synthesize serviceButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackButton:navBar];
    [self setTitle:@"Join Gravit.ly"];
    [self setNavigationBar:self.navBar title:self.navBar.topItem.title];
    SocialMediaAccountsController *smaView = [self smaView:@"Or, sign up with"];
    [socialMediaAccountsView addSubview:smaView];
    [socialMediaAccountsView setHidden:YES];
    
    [self customiseFields:signUpTableView];
    isAgreeChecked = NO;
    
    [self.signUpButton setEnabled:NO];
    [self.signUpButton setButtonColor:GVButtonGrayColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnRegister:(id)sender {
    NSLog(@"Reistering user to parse");
    NSLog(@"username: %@", txtUserName.text);
    
    
    PFUser *user = [PFUser user];
    user.username = usernameTextField.text;
    user.password = passwordTextField.text.md5Value;
    user.email = emailTextField.text;
    
    // other fields can be set just like with PFObject
    //[user setObject:@"415-392-0202" forKey:@"phone"];
   
    if (isAgreeChecked) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Signing up...";
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"user registered");
                LogInViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
                [hud removeFromSuperview];
                [self presentViewController:lvc animated:YES completion:nil];
            } else {
                if (error.code == 202) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:@"Username taken. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                } else if (error.code == 125) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:@"Incorrect Email Address. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                
                NSLog(@"error");
                [hud removeFromSuperview];
            }
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:@"You must agree to Gravit.ly's Terms and Conditions before signing up" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - Table Delegates and Data Source

- (void)customiseFields: (UITableView *)tableView {
    [self customiseTable:tableView];
    [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 264.0f)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}



//- (UIView *)inputAccessoryView
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
//    [view setBackgroundColor:[UIColor whiteColor]];
//    UIBarButtonItem *nextButton =[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextTextField)];
////    [view setBackgroundColor:[UIColor whiteColor]];
////    
////    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 44.0f)];
////    nextButton.titleLabel.text = @"Next";
////    nextButton.backgroundColor = [UIColor redColor];
////    [nextButton addTarget:self
////                   action:@selector(nextTextfield:)
////         forControlEvents:UIControlEventTouchUpInside];
////    
//    
//    [view addSubview: nextButton];
//    return view;
//}

//- (UIView *)inputAccessoryView
//{
//    
//    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    nextButton.frame = CGRectMake(0, 0, 60, 44.0f);
//    [nextButton addTarget:self action:@selector(nextTextfield:) forControlEvents:UIControlEventTouchUpInside];
//    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
//    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 44.0f)];
//    accessoryView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.6f];
//    [accessoryView addSubview:nextButton];
//}

//- (UIView *)inputAccessoryView
//{
//    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    nextButton.frame = CGRectMake(0, 0, 60, 44.0f);
//    [nextButton addTarget:self action:@selector(nextTextfield:) forControlEvents:UIControlEventTouchUpInside];
//    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
//    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 44.0f)];
//    accessoryView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.6f];
//    [accessoryView addSubview:nextButton];
//    return accessoryView;
//}

//- (UIView *)inputAccessoryView
//{
//    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    nextButton.frame = CGRectMake(0, 0, 60, 44.0f);
//    [nextButton addTarget:self action:@selector(nextTextfield:) forControlEvents:UIControlEventTouchUpInside];
//    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
//    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 44.0f)];
//    accessoryView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.6f];
//    [accessoryView addSubview:nextButton];
//    return accessoryView;
//}

- (UIView *)setInputAccessoryView:(int)rowNumber
{
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(61, 0, 60, 44.0f);
    [nextButton addTarget:self action:@selector(nextTextfield:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.tag = rowNumber;
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.frame = CGRectMake(0, 0, 60, 44.0f);
    [previousButton addTarget:self action:@selector(previousTextfield:) forControlEvents:UIControlEventTouchUpInside];
    [previousButton setTitle:@"Prev" forState:UIControlStateNormal];
    previousButton.tag = rowNumber;
   
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake((self.view.frame.size.width)-60, 0, 60, 44.0f);
    [doneButton addTarget:self action:@selector(doneTextfield:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];

    if(rowNumber == 0)
    {
        [previousButton setEnabled:NO];
        [previousButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    if(rowNumber == [signUpTableView numberOfRowsInSection:0]-1)
    {
        [nextButton setEnabled:NO];
        [nextButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 44.0f)];
    accessoryView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.6f];
    [accessoryView addSubview:nextButton];
    [accessoryView addSubview:previousButton];
    [accessoryView addSubview:doneButton];
    return accessoryView;
}

- (void)doneTextfield:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        GVTableCell *cell = (GVTableCell *)[signUpTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
        [self.view endEditing:YES];
        [cell.textField resignFirstResponder];
    }
}

- (void)previousTextfield:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        GVTableCell *cell = (GVTableCell *)[signUpTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(button.tag)-1 inSection:0]];
        [self.view endEditing:YES];
        [cell.textField becomeFirstResponder];
    }
}

- (void)nextTextfield:(id)sender
{
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        GVTableCell *cell = (GVTableCell *)[signUpTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(button.tag)+1 inSection:0]];
        [self.view endEditing:YES];
        [cell.textField becomeFirstResponder];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    GVTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"GVTableCell" owner:self options:nil];
        cell = (GVTableCell *)[nibs objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    switch (indexPath.row) {
        case 0:
            [cell.textField setPlaceholder:@"Username"];
            [cell.imageView setImage:[UIImage imageNamed:@"user.png"]];
            usernameTextField = cell.textField;
            usernameTextField.inputAccessoryView = [self setInputAccessoryView:indexPath.row];
//        usernameTextField.returnKeyType = UIReturnKeyNext;
           
            break;
        case 1:
            [cell.textField setPlaceholder:@"Password"];
            [cell.textField setSecureTextEntry:YES];
            [cell.imageView setImage:[UIImage imageNamed:@"key.png"]];
            passwordTextField = cell.textField;
            passwordTextField.inputAccessoryView = [self setInputAccessoryView:indexPath.row];
        
            break;
        case 2:
            [cell.textField setPlaceholder:@"First Name"];
            [cell.textField setSpellCheckingType:UITextSpellCheckingTypeNo];
            firstnameTextField = cell.textField;
            firstnameTextField.inputAccessoryView = [self setInputAccessoryView:indexPath.row];
            break;
        case 3:
            [cell.textField setPlaceholder:@"Last Name"];
            [cell.textField setSpellCheckingType:UITextSpellCheckingTypeNo];
            lastnameTextField = cell.textField;
            lastnameTextField.inputAccessoryView = [self setInputAccessoryView:indexPath.row];
       
            break;
        case 4:
            [cell.textField setPlaceholder:@"Email"];
            emailTextField = cell.textField;
            emailTextField.inputAccessoryView = [self setInputAccessoryView:indexPath.row];
            [emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
            [emailTextField setDelegate:self];
            break;
        case 5:
            [cell.textField setPlaceholder:@"Phone Number (optional)"];
            phoneNumberTextField = cell.textField;
            phoneNumberTextField.inputAccessoryView = [self setInputAccessoryView:indexPath.row];
            [phoneNumberTextField setKeyboardType:UIKeyboardTypeDecimalPad];
            [phoneNumberTextField setDelegate:self];
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - Back button methods

//- (void)setBackButton
//{
//    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
//    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [backButton setFrame:CGRectMake(5, 5, 32, 32)];
//    [navBar addSubview:backButton];
//}


- (void)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Textfield delegates

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.placeholder = nil;
    [self slideFrame:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (usernameTextField == textField) {
        usernameTextField.placeholder = @"Username";
    } else if (passwordTextField == textField) {
        passwordTextField.placeholder = @"Password";
    } else if (firstnameTextField == textField) {
        firstnameTextField.placeholder = @"First Name";
    } else if (lastnameTextField == textField) {
        lastnameTextField.placeholder  = @"Last Name";
    } else if (emailTextField == textField) {
        emailTextField.placeholder = @"Email";
    } else if (phoneNumberTextField == textField) {
        phoneNumberTextField.placeholder = @"Phone Number (optional)";
    }
    
    if ([usernameTextField.text length] > 0 && [passwordTextField.text length] > 0
        && [firstnameTextField.text length] > 0 && [lastnameTextField.text length] > 0
        && [emailTextField.text length] > 0) {
        [self.signUpButton setEnabled:YES];
         [self.signUpButton setButtonColor:GVButtonBlueColor];
    } else {
        [self.signUpButton setEnabled:NO];
         [self.signUpButton setButtonColor:GVButtonGrayColor];
    }
    
    [self slideFrame:NO];
}


- (void)slideFrame:(BOOL)up
{
    const int movementDistance = 140;
    const float movementDuration = 0.3f;
    int movement = (up ? -movementDistance : movementDistance);
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (IBAction)btnAgree:(id)sender {
    if (isAgreeChecked == NO) {
        [checkButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        isAgreeChecked = YES;
    } else {
        [checkButton setImage:[UIImage imageNamed:@"check-disabled.png"] forState:UIControlStateNormal];
        isAgreeChecked = NO;
    }
}

- (IBAction)btnTerms:(id)sender {
    serviceButton.highlighted = YES;

}

- (IBAction)btnPrivacyPolicy:(id)sender {
    
}

- (IBAction)btnService:(id)sender {
   termsButton.highlighted = YES;
}

- (IBAction)btnClearHighlighten:(id)sender {
    serviceButton.highlighted = NO;
    termsButton.highlighted = NO;
}


@end
