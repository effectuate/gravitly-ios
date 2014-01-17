//
//  SocialSharingViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 1/6/14.
//  Copyright (c) 2014 Geric Encarnacion. All rights reserved.
//

#import "GVBaseViewController.h"
#import <MessageUI/MessageUI.h>

@interface SocialSharingViewController : GVBaseViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) UIImage *toShareImage;
@property (strong, nonatomic) NSString *toShareLink;
@property (strong, nonatomic) NSString *toShareCaption;

@end
