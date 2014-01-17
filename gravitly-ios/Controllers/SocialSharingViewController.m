//
//  SocialSharingViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 1/6/14.
//  Copyright (c) 2014 Geric Encarnacion. All rights reserved.
//

#import "SocialSharingViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SNSHelper.h"

@interface SocialSharingViewController ()

@end

@implementation SocialSharingViewController

@synthesize toShareImage = _toShareImage, toShareLink = _toShareLink, toShareCaption = _toShareCaption;

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
    [self setNavigationBar:self.navigationBar title:self.navigationBar.topItem.title];
    [self setBackButton:self.navigationBar];
    [self.view setBackgroundColor:[GVColor backgroundDarkColor]];
    
}

- (void)backButtonTapped:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[[UITableViewCell alloc] init];
    cell.backgroundColor = [GVColor backgroundDarkBlueColor];
    
    UIView *selectedView = [[UIView alloc]init];
    selectedView.backgroundColor = [GVColor buttonBlueColor];
    cell.selectedBackgroundView =  selectedView;
    
    GVLabel *label = [[GVLabel alloc] init];
    [label setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize16];
    label.textColor = [UIColor whiteColor];
    CGRect newFrame = cell.frame;
    newFrame.origin.x = 20;
    [label setFrame:newFrame];
    [cell addSubview:label];
    
    switch (indexPath.row) {
        case 0:
            label.text = @"Share to Facebook";
            break;
        case 1:
            label.text = @"Post to Twitter";
            break;
        case 2:
            label.text = @"Email Image";
            break;
        case 3:
            label.text = @"Copy Image URL";
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self performSelector:@selector(postToFacebook)];
            break;
        case 1:
            [self performSelector:@selector(postToTwitter)];
            break;
        case 2:
            [self performSelector:@selector(attachEmailImage)];
            break;
        case 3:
            [self performSelector:@selector(copyURL)];
            break;
        default:
            break;
    }
}

#pragma mark - buttons

- (void)postToFacebook
{
    MBProgressHUD *hudw = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (!FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            switch (status) {
                case FBSessionStateOpen:
                    NSLog(@"status %i FBSessionStateOpen", status);
                    break;
                case FBSessionStateClosed:
                    NSLog(@"status %i FBSessionStateClosed", status);
                    break;
                case FBSessionStateClosedLoginFailed:
                    NSLog(@"status %i FBSessionStateClosedLoginFailed", status);
                    break;
                default:
                    break;
            }
            
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            } else if (session.isOpen) {
                NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
                [params setObject:self.toShareCaption forKey:@"message"];
                [params setObject:UIImagePNGRepresentation(self.toShareImage) forKey:@"picture"];
                
                [FBRequestConnection startWithGraphPath:@"me/photos"
                                             parameters:params
                                             HTTPMethod:@"POST"
                                      completionHandler:^(FBRequestConnection *connection,
                                                          id result,
                                                          NSError *error) {
                     if (error)
                     {
                         NSLog(@"errorr po %@", error.description);
                     }
                     else
                     {
                         NSLog(@"successful");
                         [hudw setLabelText:@"Posted!"];
                         [hudw removeFromSuperview];
                     }
                 }];
            }
        }];
    } else {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setObject:self.toShareCaption forKey:@"message"];
        [params setObject:UIImagePNGRepresentation(self.toShareImage) forKey:@"picture"];
        
        [FBRequestConnection startWithGraphPath:@"me/photos"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
             if (error)
             {
                 NSLog(@"errorr po %@", error.description);
             }
             else
             {
                 NSLog(@"successful");
                 [hudw setLabelText:@"Posted!"];
                 [hudw removeFromSuperview];
             }
         }];
    }
}

- (void)postToTwitter
{
    SNSHelper *sns = [[SNSHelper alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hudw = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sns tweet:self.toShareCaption withImage:self.toShareImage block:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    NSLog(@">>>>>>>>> FAIL %@ ", error.debugDescription);
                }
                [hudw removeFromSuperview];
            }];
        });
    });
}

#pragma mark - Mail

- (void)attachEmailImage
{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {
        [mc setMailComposeDelegate:self];
        [mc setSubject:@"Gravitly"];
        [mc setMessageBody:@"Gravitly" isHTML:NO];
        
        // Add attachment
        [mc addAttachmentData:UIImagePNGRepresentation(self.toShareImage) mimeType:@"image/png" fileName:@"Gravitly"];
        
        [self presentViewController:mc animated:YES completion:NULL];
    } else {
        [mc setMailComposeDelegate:nil];
    }
}

- (void)copyURL
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Copied for pasting!"];
    [hud setMode:MBProgressHUDModeText];
    
    [self performSelector:@selector(hudshit) withObject:nil afterDelay:0.3];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.toShareLink;
    NSLog(@" PASTEBOARD ------- %@", self.toShareLink);
}

- (void)hudshit
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            NSLog(@">>>>>> DEFAULT");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
