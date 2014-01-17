//
//  PostPhotoViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/10/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVBaseViewController.h"
#import "SNSHelperDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <MLPAutoCompleteTextField.h>
#import "Activity.h"
#import "Metadata.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <TMAPIClient.h>

@interface PostPhotoViewController : GVBaseViewController<UITextViewDelegate, CLLocationManagerDelegate, MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, GPPSignInDelegate, UIWebViewDelegate> {
    id <SNSHelperDelegate> snsDelegate;
}

@property (nonatomic, strong) UIImage *imageHolder;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet GVTextView *captionTextView;
@property (strong, nonatomic) IBOutlet UIView *smaView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain) id snsDelegate;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) Activity *selectedActivity;
@property (strong, nonatomic) IBOutlet UITableView *metadataTableView;
@property (strong, nonatomic) NSMutableDictionary *enhancedMetadata;
@property (strong, nonatomic) Metadata *basicMetadata;
@property (weak, nonatomic) IBOutlet UIView *line;
//
@property NSMutableDictionary *placesApiLocations;

//TODO:Delete
@property (strong, nonatomic) IBOutlet GVButton *activityButton;
@property (strong, nonatomic) IBOutlet GVButton *enhancementsButton;

- (IBAction)addActivity:(id)sender;
- (IBAction)addEnhancement:(id)sender;

@end
