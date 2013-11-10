//
//  PhotoDetailsViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 8/29/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVBaseViewController.h"

@interface PhotoDetailsViewController : GVBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *feeds;
@property (strong, nonatomic) IBOutlet UITableView *photoFeedTableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) NSString *parent;

@end
