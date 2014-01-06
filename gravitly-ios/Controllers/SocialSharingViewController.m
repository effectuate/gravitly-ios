//
//  SocialSharingViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 1/6/14.
//  Copyright (c) 2014 Geric Encarnacion. All rights reserved.
//

#import "SocialSharingViewController.h"

@interface SocialSharingViewController ()

@end

@implementation SocialSharingViewController

@synthesize toShareImage = _toShareImage, toShareLink = _toShareLink;

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
    NSLog(@">>>>>>>>> POST TO FB");
}

- (void)postToTwitter
{
    NSLog(@">>>>>>>>> POST TO TWITTER");
}

- (void)attachEmailImage
{
    NSLog(@">>>>>>>>> EMAYL");
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
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.toShareLink;
    NSLog(@" PASTEBOARD ------- %@", self.toShareLink);
}

#pragma mark - Mail
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
