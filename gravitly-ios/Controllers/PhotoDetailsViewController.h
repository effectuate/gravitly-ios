//
//  PhotoDetailsViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 8/29/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *feeds;
@property (strong, nonatomic) IBOutlet UITableView *photoFeedTableView;

@end
