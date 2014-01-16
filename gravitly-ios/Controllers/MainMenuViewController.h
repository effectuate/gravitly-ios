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

@interface MainMenuViewController : GVBaseViewController <UINavigationControllerDelegate, NMPaginatorDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIWebViewDelegate, UITextViewDelegate>


- (IBAction)btnTakePhoto:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnGrabIt:(id)sender;
- (IBAction)btnCameraRoll:(id)sender;
- (IBAction)btnGallery:(id)sender;
- (IBAction)btnLogout:(id)sender;

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) UILabel *footerLabel;
@property (getter = isUsingNearGeoPointQuery) BOOL usingNearGeoPointQuery;

-(void)refresh;
-(void)initMainMenu;



@end
