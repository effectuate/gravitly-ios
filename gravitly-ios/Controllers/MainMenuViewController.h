//
//  MainMenuViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVButton.h"
#import "GVBaseViewController.h"
#import "GVPhotoFeedPaginator.h"

@interface MainMenuViewController : GVBaseViewController <UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, NMPaginatorDelegate, UIScrollViewDelegate>


- (IBAction)btnTakePhoto:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnGrabIt:(id)sender;
- (IBAction)btnCameraRoll:(id)sender;
- (IBAction)btnGallery:(id)sender;

- (IBAction)btnLogout:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *photoFeedTableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property UIActivityIndicatorView *activityIndicator;
@property NMPaginator *paginator;
@property UILabel *footerLabel;

@end
