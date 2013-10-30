//
//  GVTableViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/30/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVPhotoFeedPaginator.h"

@interface GVTableViewController : UITableViewController <NMPaginatorDelegate>

@property (strong, nonatomic) IBOutlet UITableView *photoFeedTableView;

@property UIActivityIndicatorView *activityIndicator;
@property NMPaginator *paginator;
@property UILabel *footerLabel;

@end
