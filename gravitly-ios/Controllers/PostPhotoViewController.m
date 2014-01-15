//
//  PostPhotoViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/10/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

//TODO:change url
//#define BASE_URL @"http://192.168.0.128:8080/" //local
//#define BASE_URL @"http://192.168.0.123:19001/" //local

#define BASE_URL @"http://webapi.webnuggets.cloudbees.net"
#define ENDPOINT_UPLOAD @"admin/upload"
#define TAG_LOCATION_NAV_BAR 201
#define TAG_LOCATION_TEXT 202
#define TAG_LOCATION_SUBMIT_BUTTON 203
#define TAG_LOCATION_NAV_BAR_BACK_BUTTON 204
#define TAG_ACTIVITY_LABEL 401
#define TAG_METADATA_TEXTFIELD 402
#define TAG_SHARE_BUTTON 403
#define TAG_LOCK_BUTTON 404
#define TAG_PRIVACY_LABEL 700
#define TAG_PRIVACY_DROPDOWN 701
#define TAG_PRIVACY_LOCK_IMAGE 702
#define I_NEED_METRIC 0
#define I_NEED_FAHRENHEIT 1

#define FORBID_FIELDS_ARRAY @[@"community", @"region", @"country", @"Elevation M", @"Elevation F"]
#define ADDITIONAL_FIELDS_ARRAY @[@"Tag"]


#import "PostPhotoViewController.h"
//#import <AFNetworkActivityIndicatorManager.h>
#import <AFHTTPRequestOperation.h>
//#import <AFHTTPClient.h>
//#import <AFHTTPRequestOperationManager.h>
#import <MBProgressHUD.h>
#import "SNSHelper.h"
#import <Parse/Parse.h>
#import "UTF8Helper.h"
#import "Metadata.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/CGImageProperties.h>
#import "PhotoDetailsViewController.h"
#import "Feed.h"
#import "GVWebHelper.h"
#import "GVActivityField.h"
#import "GVMetadataCell.h"
#import <QuartzCore/QuartzCore.h>
#import <AFHTTPClient.h>

#import <ImageIO/ImageIO.h>

#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"
#import "GVFlickr.h"
#import "CameraViewController.h"
#import "NSNumber+GVUnitConverter.h"

@interface PostPhotoViewController ()

@end

@implementation PostPhotoViewController {
    MBProgressHUD *hud;
    UIView *locationView;
    UINavigationBar *locationViewNavBar;
    UIButton *submitButton;
    MLPAutoCompleteTextField *autocompleteTextField;
    UIView *overlayView;
    CGRect locationViewOriginalFrame;
    CGRect submitLocationOriginalFrame;
    NSString *isPrivate;
    
    UIImageView *privacyImageView;
    GVLabel *privacyLabel;
    UIButton *privacyDropdownButton;
    
    NSMutableArray *privateHashTagKeys;
    UIControl *captionViewPlaceholder;
    
    NSMutableArray *activityFieldsArray;
    NSString *locationName;
    NSData *imageDataToUpload;
    SocialMediaAccountsController *sma;
}

@synthesize imageHolder;
@synthesize thumbnailImageView;
@synthesize captionTextView;
@synthesize smaView;
@synthesize activityButton;
@synthesize enhancementsButton;
@synthesize navBar;
@synthesize locationManager;
@synthesize selectedActivity;
@synthesize placesApiLocations;
@synthesize metadataTableView;
@synthesize enhancedMetadata;
@synthesize basicMetadata;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"frob"]) {
        GVFlickr *flickr = [[GVFlickr alloc] init];
        [flickr getAuthTokenWithFrob:[[NSUserDefaults standardUserDefaults] objectForKey:@"frob"]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    placesApiLocations = [[NSMutableDictionary alloc] init];
    
    [self.navigationItem setTitle:@"Post"];
    [self setNavigationBar:navBar title:navBar.topItem.title];
    [self setBackButton:navBar];
    [self setRightBarButtons];
    [self.captionTextView setDelegate:self];
    
    [self setSocialMediaView];
    
    [self initPrivacyView];
    
    [self.thumbnailImageView setImage: self.imageHolder];
    captionTextView.delegate = self;
    snsDelegate = [[SNSHelper alloc] init];
    
    //location
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    //private hashtags
    privateHashTagKeys = [NSMutableArray array];
    
    //placeholder
    [self createCaptionTextViewPlaceholder];
    [self addInputAccessoryViewForTextView:captionTextView];
    
    [self combineEnhancedMetadata];
    isPrivate = @"true"; //default
    
    if (IS_IPHONE_5) {
        NSLog(@"IPHONE 5 TEST");
        //buttonSize = 100;
    } else {
        //[captionTextView setFrame:CGRectMake(307.0f, 56.0f, CGRectGetWidth(captionTextView.frame), CGRectGetHeight(captionTextView.frame))];
        //buttonSize = 58;
        //[self.line setHidden:YES];
        //[activityLabel setFrame:CGRectMake(activityLabel.frame.origin.x, activityLabel.frame.origin.y - 18, CGRectGetWidth(activityLabel.frame), CGRectGetHeight(activityLabel.frame))];
        //[activityScrollView setFrame:CGRectMake(activityScrollView.frame.origin.x, activityScrollView.frame.origin.y - 40, CGRectGetWidth(activityScrollView.frame), CGRectGetHeight(activityScrollView.frame))];
    }
    
}

- (NSArray *)forbid {
    return (NSArray *)FORBID_FIELDS_ARRAY;
}

- (NSArray *)additional {
    return (NSArray *)ADDITIONAL_FIELDS_ARRAY;
}

#pragma mark - Social Media View

-(void)setSocialMediaView
{
    sma = [self smaView:@"Share to:"];
    [sma setFrame:CGRectMake(sma.frame.origin.x, sma.frame.origin.y + 10, sma.frame.size.width, sma.frame.size.height)];
    [sma setBackgroundColor:[GVColor backgroundDarkColor]];
    [sma.facebookButton addTarget:self action:@selector(shareToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [sma.twitterButton addTarget:self action:@selector(shareToTwitter:) forControlEvents:UIControlEventTouchUpInside];
    [sma.googlePlusButton addTarget:self action:@selector(postToGooglePlus:) forControlEvents:UIControlEventTouchUpInside];
    [sma.flickrButton addTarget:self action:@selector(shareToFlickr:) forControlEvents:UIControlEventTouchUpInside];
    
    [smaView addSubview:sma];
    
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [sma.facebookButton setImage:[UIImage imageNamed:@"button-facebook.png"] forState:UIControlStateNormal];
        [sma.facebookButton setTag:1];
    } else {
        [sma.facebookButton setImage:[UIImage imageNamed:@"button-facebook-gray.png"] forState:UIControlStateNormal];
        [sma.facebookButton setTag:0];
        [sma.facebookButton setEnabled:NO];
    }
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        [sma.twitterButton setImage:[UIImage imageNamed:@"button-twitter.png"] forState:UIControlStateNormal];
        [sma.twitterButton setTag:1];
    } else {
        [sma.twitterButton setImage:[UIImage imageNamed:@"button-twitter-gray.png"] forState:UIControlStateNormal];
        [sma.twitterButton setTag:0];
        [sma.twitterButton setEnabled:NO];
    }
    if ([GVFlickr isLinkedWithUser:[PFUser currentUser]]) {
        [sma.flickrButton setImage:[UIImage imageNamed:@"button-yahoo-new.png"] forState:UIControlStateNormal];
        [sma.flickrButton setTag:1];
    } else {
        [sma.flickrButton setImage:[UIImage imageNamed:@"button-yahoo-gray-new.png"] forState:UIControlStateNormal];
        [sma.flickrButton setTag:0];
        [sma.flickrButton setEnabled:NO];
    }
}

#pragma mark - Button

- (void)shareToFacebook: (UIButton *)sender
{
    if (sender.tag == 0) {
        [sender setImage:[UIImage imageNamed:@"button-facebook.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    } else {
        [sender setImage:[UIImage imageNamed:@"button-facebook-gray.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

- (void)shareToTwitter: (UIButton *)sender
{
    if (sender.tag == 0) {
        [sender setImage:[UIImage imageNamed:@"button-twitter.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    } else {
        [sender setImage:[UIImage imageNamed:@"button-twitter-gray.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

- (void)shareToFlickr: (UIButton *)sender
{
    if (sender.tag == 0) {
        [sender setImage:[UIImage imageNamed:@"button-yahoo-new.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    } else {
        [sender setImage:[UIImage imageNamed:@"button-yahoo-gray-new.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

#pragma mark - initialization

- (void)combineEnhancedMetadata {
    NSArray *allKeys = [enhancedMetadata allKeys]; //from web json
    activityFieldsArray = [[NSMutableArray alloc] init];
    
    GVWebHelper *helper = [[GVWebHelper alloc] init];
    for (GVActivityField *actField in [helper fieldsForActivity:selectedActivity.name]) {
        BOOL isNotForbidden = ![self.forbid containsObject:actField.name];
        BOOL isAbsentOnEnhanced = ![allKeys containsObject:actField.name];
        
        if (isNotForbidden) {
            if (isAbsentOnEnhanced) { //present in mapping absent in web json
                [enhancedMetadata setObject:@"" forKey:actField.name.description];
            }
            [activityFieldsArray addObject:actField];
        }
    }
    
    //additional fields
    for (NSString *act in [self additional]) {
        NSString *key = act;
        [enhancedMetadata setObject:@"" forKey:key];
        GVActivityField *actField = [[GVActivityField alloc] init];
        actField.name = key;
        if ([act isEqualToString:@"Tag"] && IS_LITE) {
            actField.displayName = @"Tag";
            actField.tagFormat = @"@gravitly";
            actField.editable = 0;
            [activityFieldsArray addObject:actField];
        }
    }
    
    //setting of activity name
    [enhancedMetadata setObject:selectedActivity.tagName forKey:@"ActivityName"];
}

#pragma mark - Privacy

- (void)initPrivacyView {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setPrivacy)];
    [tap setDelegate:self];
    [tap setNumberOfTapsRequired:1];
    
    UIView *privacyView = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"PrivacyView" owner:self options:nil] objectAtIndex:0];
    [smaView addSubview:privacyView];
    
    privacyImageView = (UIImageView *)[privacyView viewWithTag:TAG_PRIVACY_LOCK_IMAGE];
    privacyLabel = (GVLabel *)[privacyView viewWithTag:TAG_PRIVACY_LABEL];
    [privacyLabel setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize18];
    [privacyView addGestureRecognizer:tap];
    privacyDropdownButton = (UIButton *)[privacyView viewWithTag:TAG_PRIVACY_DROPDOWN];
    [privacyDropdownButton addTarget:self action:@selector(setPrivacy) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setPrivacy {
    if ([isPrivate isEqualToString:@"true"]) { //is true already, change to false
        isPrivate = @"false";
        [privacyImageView setImage:[UIImage imageNamed:@"lock-open.png"]];
        [privacyLabel setText:@"Share to: Public (Default)"];
    } else {
        isPrivate = @"true";
        [privacyImageView setImage:[UIImage imageNamed:@"lock-close.png"]];
        [privacyLabel setText:@"Share to: Private Only"];
    }
}

#pragma mark - Gesture Recognizer Delegates

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - create placeholder for text view
- (void)createCaptionTextViewPlaceholder {
    //placeholder
    
    GVLabel *label = [[GVLabel alloc] init];
    [label setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize];
    [label setText:@"Add Caption"];
    
    CGRect frame = captionTextView.frame;
    CGSize size = frame.size;
    CGPoint point = frame.origin;
    CGRect newFrame = CGRectMake(3, 5, size.width, size.height / 4);
    
    [label setFrame:newFrame];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(captionTextViewTapped:)];
    
    captionViewPlaceholder = [[UIControl alloc] initWithFrame:frame];
    [captionViewPlaceholder addSubview:label];
    [captionViewPlaceholder addGestureRecognizer:tap];
    [self.captionTextView.superview addSubview:captionViewPlaceholder];
}

- (void)captionTextViewTapped:(id)sender
{
    [captionViewPlaceholder setHidden:YES];
    [captionTextView becomeFirstResponder];
}


#pragma mark - picker delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location view

- (void)showLocationView {
    locationView = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"LocationView" owner:self options:nil] objectAtIndex:0];
    locationViewNavBar = (UINavigationBar *)[locationView viewWithTag:TAG_LOCATION_NAV_BAR];
    [self setBackButton:locationViewNavBar];
    
    
    //locationBackButton = (UIBarButtonItem *)[locationView viewWithTag:TAG_LOCATION_NAV_BAR_BACK_BUTTON];
    
    
    submitButton = (UIButton *)[locationView viewWithTag:TAG_LOCATION_SUBMIT_BUTTON];
    [submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    
    autocompleteTextField = (MLPAutoCompleteTextField *)[locationView viewWithTag:TAG_LOCATION_TEXT];
    [autocompleteTextField setDelegate:self];
    [autocompleteTextField setAutoCompleteDelegate:self];
    [autocompleteTextField setAutoCompleteDataSource:self];
    
    //[self setNavigationBar:metadataNavBar title:metadataNavBar.topItem.title];
    
    float newXPos = (self.view.frame.size.width - locationView.frame.size.width) / 2;
    float newYPos = self.navBar.frame.size.height + 15;
    [locationView setFrame:CGRectMake(newXPos, newYPos, locationView.frame.size.width, locationView.frame.size.height)];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationDelegate:self];
    [locationView setAlpha:1.0f];
    [self.view addSubview:locationView];
    [UIView commitAnimations];
    
    locationViewOriginalFrame = locationView.frame;
    submitLocationOriginalFrame = submitButton.frame;
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:[NSString stringWithFormat:@"Retrieving metadata"]];
    [hud hide:YES];
}

#pragma mark - Nav buttons


- (void)setRightBarButtons {
    
    UIButton *proceedButton = [self createButtonWithImageNamed:@"check-big.png"];
    [proceedButton addTarget:self action:@selector(proceedButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [proceedButton setFrame:CGRectMake(-1, 0, 50, 44)];
    [proceedButton setBackgroundColor:[GVColor buttonBlueColor]];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.borderColor = [GVColor backgroundDarkColor].CGColor;
    rightBorder.borderWidth = 1.0f;
    rightBorder.frame = CGRectMake(0, 0, 1, CGRectGetHeight(proceedButton.frame));
    [proceedButton.layer addSublayer:rightBorder];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:proceedButton];
    [barButton setBackgroundVerticalPositionAdjustment:-20.0f forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0f) {
        negativeSpacer.width = -16;
    } else {
        negativeSpacer.width = -6; //ios 6 below
    }
    
    [navBar.topItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButton, nil] animated:NO];
    
}

-(IBAction)lockTapped:(id)sender {
    NSLog(@"tinap mo ung lock");
}


-(NSString *)getCaptionHashTag
{
    NSString *captionWithHashTags = captionTextView.text;
    
    for (int i = 0;i < activityFieldsArray.count+1;i++) {
        GVActivityField *activity = (GVActivityField *)[activityFieldsArray objectAtIndex:i];
        
        //value
        NSString *data = (NSString *)[enhancedMetadata objectForKey:activity.name];
        
        if (![privateHashTagKeys containsObject:activity.name] && ![self.forbid containsObject:activity.name] && data.length) {
            data = [activity.tagFormat stringByReplacingOccurrencesOfString:@"x" withString:data];
            captionWithHashTags = [captionWithHashTags stringByAppendingString:@" "];
            captionWithHashTags = [captionWithHashTags stringByAppendingString:data];
        }
    }
    return captionWithHashTags;
}

#pragma mark - Upload Image

- (void)upload {
    NSURL *url = [NSURL URLWithString:BASE_URL];
    //NSData *data = UIImageJPEGRepresentation(imageHolder, 1.0);
    NSString *userId = [PFUser currentUser].objectId;
    
    static NSString *imageKey = @"image";
    static NSString *captionKey = @"caption";
    static NSString *filenameKey = @"filename";
    static NSString *userKey = @"userKey";
    static NSString *categoryKey = @"category";
    static NSString *locationKey = @"location";
    static NSString *isPrivateKey = @"isPrivate";
    static NSString *locationNameKey = @"locationName";
    
    NSString *filename = @"temp.jpg";
    
    if (imageDataToUpload) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       captionTextView.text, captionKey,
                                       filename, filenameKey,
                                       userId, userKey, //TODO: static
                                       selectedActivity.objectId, categoryKey,
                                       @"u6ffhvdZJH", locationKey, //TODO: static Heavenly Mountain
                                       isPrivate, isPrivateKey,
                                       locationName, locationNameKey,
                                       nil];
        [params addEntriesFromDictionary:[self publicHashTags]];
        
        NSLog(@">>> PARAMS <<<< /n %@", params);
        
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:url];
        [client clearAuthorizationHeader];
        [client setDefaultHeader:@"X-Gravitly-Client-Id" value:X_GRAVITLY_CLIENT_ID];
        [client setDefaultHeader:@"X-Gravitly-REST-API-Key" value:X_GRAVITLY_REST_API_KEY];
        //[client setValue:@"X-GRAVITLY_CLIENT_ID" forKey:<#(NSString *)#>]
        //        [client setAuthorizationHeaderWithUsername:X_GRAVITLY_CLIENT_ID password:X_GRAVITLY_REST_API_KEY];
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:ENDPOINT_UPLOAD parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageDataToUpload name:imageKey fileName:filename mimeType:@"image/jpeg"];
        }];
        
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setLabelText:[NSString stringWithFormat:@"Uploading"]];
        
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            int percentage = ceil(((float)totalBytesWritten / (float)totalBytesExpectedToWrite ) * 100.0f);
            [hud setLabelText:[NSString stringWithFormat:@"Uploading %i %%", percentage]];
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject) {
                @try {
                    [self performSelector:@selector(postToTwitter)];
                    [self performSelector:@selector(postToFacebook:)];
                    [self performSelector:@selector(postToFlickr:)];
                }
                @catch (NSException *exception) {
                    NSLog(@"ERROR ON FACEBOOK OR TWITTER");
                }
                [self presentUserView];
                NSLog(@"Upload Success!");
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if([operation.response statusCode] == 403)
            {
                NSLog(@"Upload Failed");
                return;
            }
            if (error) {
                NSLog(@"Error %@", error);
                [hud setLabelText:[NSString stringWithFormat:@"Upload Failed"]];
                [NSThread sleepForTimeInterval:1];
                [hud removeFromSuperview];
            }
        }];
        
        [operation start];
    }
}



- (void)prepareImageDataFromLibraryWithUrl: (NSURL *)assetUrl {
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            //attaching metadata to nsdata
            imageHolder = [UIImage imageWithCGImage:iref];
            
            NSData *jpeg = [NSData dataWithData:UIImageJPEGRepresentation(imageHolder, 1.0)];
            
            CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
            
            NSDictionary *metadata = [rep metadata];
            
            NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
            
            NSMutableDictionary *EXIFDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary];
            NSMutableDictionary *GPSDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
            NSMutableDictionary *TIFFDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
            NSMutableDictionary *RAWDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyRawDictionary];
            NSMutableDictionary *JPEGDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyJFIFDictionary];
            NSMutableDictionary *GIFDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            
            if(!EXIFDictionary) {
                EXIFDictionary = [NSMutableDictionary dictionary];
            }
            
            if(!GPSDictionary) {
                GPSDictionary = [NSMutableDictionary dictionary];
            }
            
            if (!TIFFDictionary) {
                TIFFDictionary = [NSMutableDictionary dictionary];
            }
            
            if (!RAWDictionary) {
                RAWDictionary = [NSMutableDictionary dictionary];
            }
            
            if (!JPEGDictionary) {
                JPEGDictionary = [NSMutableDictionary dictionary];
            }
            
            if (!GIFDictionary) {
                GIFDictionary = [NSMutableDictionary dictionary];
            }
            
            [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
            [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
            [metadataAsMutable setObject:TIFFDictionary forKey:(NSString *)kCGImagePropertyTIFFDictionary];
            [metadataAsMutable setObject:RAWDictionary forKey:(NSString *)kCGImagePropertyRawDictionary];
            [metadataAsMutable setObject:JPEGDictionary forKey:(NSString *)kCGImagePropertyJFIFDictionary];
            [metadataAsMutable setObject:GIFDictionary forKey:(NSString *)kCGImagePropertyGIFDictionary];
            
            CFStringRef UTI = CGImageSourceGetType(source);
            
            NSMutableData *dest_data = [NSMutableData data];
            
            CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
            
            CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadataAsMutable);
            
            BOOL success = NO;
            success = CGImageDestinationFinalize(destination);
            
            if(!success) {
            }
            
            imageDataToUpload = dest_data;
            
            CFRelease(destination);
            CFRelease(source);
            NSLog(@">>>>> IMAGE METADATA ATTACHED TO IMAGE DATA <<<<<");
            [self upload];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *error)
    {
        imageHolder = nil;
        imageDataToUpload = nil;
        NSLog(@">>>>> IMAGE ERROR <<<<< - \n %@",[error localizedDescription]);
        [self upload];
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:assetUrl
                   resultBlock:resultblock
                  failureBlock:failureblock];
}

- (void)saveImageToLibraryWithMetadata:(NSMutableDictionary *)metadata {
    //add metadata here + save to photo album..
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:self.thumbnailImageView.image.CGImage metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error == nil) {
            NSLog(@">>>>> IMAGE SAVED IN PHOTO ALBUM <<<<<");
            NSLog(@"Asset URL %@", assetURL.URLByStandardizingPath);
            [self prepareImageDataFromLibraryWithUrl:assetURL];
        } else {
            NSLog(@"error");
        }
    }];
}

- (NSMutableDictionary *)createImageMetadata {
    //sources: https://raw.github.com/sburel/cordova-ios-1/cc8956342b2ce2fafa93d1167be201b5b108d293/CordovaLib/Classes/CDVCamera.m
    // https://github.com/lorinbeer/cordova-ios/pull/1/files
    
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    //[metadata setObject:@"caption" forKey:@"txtCaption"];
    
    NSMutableDictionary *tiffMetadata = [[NSMutableDictionary alloc] init];
    [tiffMetadata setObject:captionTextView.text forKey:(NSString*)kCGImagePropertyTIFFImageDescription];
    
    [metadata setObject:tiffMetadata forKey:(NSString*)kCGImagePropertyTIFFDictionary];
    
    NSMutableDictionary *GPSDictionary = [[NSMutableDictionary alloc] init];
    //CLLocation *newLocation = locationManager.location;
    
    CLLocationDegrees latitude  = basicMetadata.latitude.floatValue;//newLocation.coordinate.latitude;
    CLLocationDegrees longitude = basicMetadata.longitude.floatValue;//newLocation.coordinate.longitude;
    CLLocationDistance altitude = basicMetadata.altitude.floatValue;//newLocation.altitude;
    
    //latitude
    if (latitude < 0.0) {
        latitude = latitude * -1.0f;
        [GPSDictionary setObject:@"S" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    } else {
        [GPSDictionary setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    }
    [GPSDictionary setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    
    // lontitude
    if (longitude < 0.0) {
        longitude = longitude * -1.0f;
        [GPSDictionary setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    }
    else {
        [GPSDictionary setObject:@"E" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    }
    
    [GPSDictionary setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];
    [GPSDictionary setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    
    [metadata setObject:GPSDictionary forKey:(NSString*)kCGImagePropertyGPSDictionary];
    
    return metadata;
    
}


-(void)proceedButtonTapped {
    //if (captionTextView.text.length != 0) {
    
    NSLog(@">>>>>>>>> privacy is %@", isPrivate);
    NSLog(@">>>>>>>>> location name is %@", locationName);
    
    if (locationName == nil) {
        locationName = @"";
    }
    
    NSMutableDictionary *metadata = [self createImageMetadata];
    
    [self saveImageToLibraryWithMetadata:metadata];
    
    /*} else {
     dispatch_async(dispatch_get_main_queue(), ^{
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Gravit.ly" message:@"Caption field empty!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
     [alertView show];
     dispatch_async(dispatch_get_main_queue(), ^{
     [captionTextView becomeFirstResponder];
     });
     });
     }*/
}

- (void)setLocation:(NSMutableDictionary *)metadata location:(CLLocation *)location
{
    
    if (location) {
        
        CLLocationDegrees exifLatitude  = location.coordinate.latitude;
        CLLocationDegrees exifLongitude = location.coordinate.longitude;
        
        NSString *latRef;
        NSString *lngRef;
        
        
        if (exifLatitude < 0.0) {
            exifLatitude = exifLatitude * -1.0f;
            latRef = @"S";
        } else {
            latRef = @"N";
        }
        
        if (exifLongitude < 0.0) {
            exifLongitude = exifLongitude * -1.0f;
            lngRef = @"W";
        } else {
            lngRef = @"E";
        }
        
        
        NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];
        if ([metadata objectForKey:(NSString*)kCGImagePropertyGPSDictionary]) {
            [locDict addEntriesFromDictionary:[metadata objectForKey:(NSString*)kCGImagePropertyGPSDictionary]];
        }
        [locDict setObject:location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
        [locDict setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
        [locDict setObject:lngRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];
        [locDict setObject:[NSNumber numberWithFloat:location.horizontalAccuracy] forKey:(NSString*)kCGImagePropertyGPSDOP];
        [locDict setObject:[NSNumber numberWithFloat:location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
        
        [metadata setObject:locDict forKey:(NSString*)kCGImagePropertyGPSDictionary];
    }
}

#pragma mark - Text View method

- (void)addInputAccessoryViewForTextView:(UITextView *)textView{
    
    //Create the toolbar for the inputAccessoryView
    UIToolbar* toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    [toolbar sizeToFit];
    [toolbar setTranslucent:YES]; //iOS 7
    [toolbar setBackgroundColor:[UIColor whiteColor]];
    toolbar.barStyle = UIBarStyleDefault;
    
    //Add the done button and set its target:action: to call the method returnTextView:
    toolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                     [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(returnTextView:)],
                     nil];
    
    //Set the inputAccessoryView
    [textView setInputAccessoryView:toolbar];
    
}

- (void) returnTextView:(UIButton *)sender{
    if (captionTextView.text.length == 0) {
        [captionViewPlaceholder setHidden:NO];
    } else {
        [captionViewPlaceholder setHidden:YES];
        [captionTextView setNeedsDisplay];
    }
    [captionTextView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [captionViewPlaceholder setHidden:YES];
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length > 0) {
        //[captionTextView removeFromSuperview];
    } else {
        //[self createCaptionTextViewPlaceholder];
    }
    [textView resignFirstResponder];
}

#pragma mark - MLPAutoCompleteTextField DataSource

//example of asynchronous fetch:
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
    NSLog(@"completion handler ..");
    if (string.length > 2) {
        NSString *catId = selectedActivity.objectId;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(queue, ^{
            PFQuery *query = [PFQuery queryWithClassName:@"Location"];
            [query whereKey:@"name" containsString:string];
            [query whereKey:@"categories" equalTo:catId];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSMutableArray *completions = [[NSMutableArray alloc] init];
                    NSLog(@"Successfully retrieved %d scores.", objects.count);
                    
                    if (objects.count > 0) {
                        for (PFObject *object in objects) {
                            [completions addObject:[object valueForKey:@"name"]];
                        }
                        
                        newLocation = FALSE;
                        handler(completions);
                    } else {
                        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment&location=%f,%f&radius=1000&sensor=true&key=AIzaSyBoLmFUrh93yhHgj66fXsmYBENARWlBUf0", string, lastLocation.coordinate.latitude, lastLocation.coordinate.longitude];
                        
                        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:urlString]];
                        
                        [client getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseData) {
                            NSError *error = nil;
                            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
                            NSArray *jsonArray = [jsonData valueForKeyPath:@"predictions"];
                            
                            for (int i = 0; i < [jsonArray count]; i++)
                            {
                                NSDictionary *dict = [jsonArray objectAtIndex:i];
                                NSLog(@"### types: %@", [dict objectForKey:@"types"]);
                                [completions addObject:[dict objectForKey:@"description"]];
                                
                                [placesApiLocations setValue:[dict objectForKey:@"reference"] forKey:[dict objectForKey:@"description"]];
                            }
                            newLocation = TRUE;
                            handler(completions);
                            
                            [operation start];
                            
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Error: %@ %@", error, error.userInfo);
                        }];
                    }
                    
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        });
    }
}

static bool newLocation = FALSE;

#pragma mark - MLPAutoCompleteTextField Delegate

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    //resize the view when there are results
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationDelegate:self];
    CGRect lastFrame = locationViewOriginalFrame;
    locationView.frame = CGRectMake(lastFrame.origin.x, lastFrame.origin.y, lastFrame.size.width, lastFrame.size.height + 110.0f);
    lastFrame = submitButton.frame;
    submitButton.frame = CGRectMake(lastFrame.origin.x, lastFrame.origin.y + 110.0f, lastFrame.size.width, lastFrame.size.height);
    [UIView commitAnimations];
}


- (BOOL)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
          shouldConfigureCell:(UITableViewCell *)cell
       withAutoCompleteString:(NSString *)autocompleteString
         withAttributedString:(NSAttributedString *)boldedString
        forAutoCompleteObject:(id<MLPAutoCompletionObject>)autocompleteObject
            forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //This is your chance to customize an autocomplete tableview cell before it appears in the autocomplete tableview
    NSString *filename = [autocompleteString stringByAppendingString:@".png"];
    filename = [filename stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    filename = [filename stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
    [cell.imageView setImage:[UIImage imageNamed:filename]];
    return YES;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedObject){
        NSLog(@"selected object from autocomplete menu %@ with string %@", selectedObject, [selectedObject autocompleteString]);
    } else {
        NSLog(@"selected string '%@' from autocomplete menu", selectedString);
    }
}

#pragma mark - Location

static CLLocation *lastLocation;

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    lastLocation = [locations lastObject];
    NSLog(@">>>>>>>>>>>>> updating location");
}

#pragma mark - Textfield delegates

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self slideFrame:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    GVActivityField *actField = [activityFieldsArray objectAtIndex:textField.tag];
    NSString *newText = textField.text;
    
    if (textField.text.length > 1) {
        if ([[newText substringToIndex:1] isEqualToString:@"#"]) {
            newText = [textField.text stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:@""];
        }
        [enhancedMetadata setObject:newText forKey:actField.name];
        
        //location name
        if ([actField.displayName isEqualToString:@"Location"]) {
            locationName = newText;
        }
    } else {
        textField.text = @"#";
    }
    
    [self slideFrame:NO];
}

- (void)slideFrame:(BOOL)up
{
    const int movementDistance = 50;
    const float movementDuration = 0.3f;
    int movement = (up ? -movementDistance : movementDistance);
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark - Table View delegate and datasource


- (void)customiseFields: (UITableView *)tableView {
    [self customiseTable:tableView];
    [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 224.0f)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return activityFieldsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    GVMetadataCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSLog(@">>>>>>>>> %i", indexPath.row);
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"MetadataCell" owner:self options:nil];
        cell = (GVMetadataCell *)[nibs objectAtIndex:0];
    }
    
    GVLabel *activityLabel = (GVLabel *)[cell viewWithTag:TAG_ACTIVITY_LABEL];
    [activityLabel setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize16];
    UIButton *shareButton = (UIButton *)[cell viewWithTag:TAG_SHARE_BUTTON];
    UIButton *lockButton = (UIButton *)[cell viewWithTag:TAG_LOCK_BUTTON];
    
    GVActivityField *actField = [activityFieldsArray objectAtIndex:indexPath.row];
    
    GVTextField *metadataTextField = cell.metadataTextfield;
    [metadataTextField setDefaultFontStyleWithSize:kgvFontSize16];
    [metadataTextField setTag:indexPath.row];
    [metadataTextField setDelegate:self];
    
    //retrieval and replacing of values from tag format
    NSString *data = [enhancedMetadata objectForKey:actField.name];
    NSString *metadata = data ? [NSString stringWithFormat:@"%@", data] : @"";
    
    //conversion
    if (actField.unit) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *toConvert = [f numberFromString:data];
        NSNumber *imperial;
        NSNumber *metric;
        NSString *imperialUnit;
        NSString *metricUnit;
        
        if ([GVWebHelper isMetricUnit:actField.unit]) {
            metric = toConvert;
            imperial = [toConvert convertFromUnit:actField.unit toUnit:actField.subUnit];
            metricUnit = actField.unit;
            imperialUnit = actField.subUnit;
        } else {
            metric = [toConvert convertFromUnit:actField.unit toUnit:actField.subUnit];
            imperial = toConvert;
            metricUnit = actField.subUnit;
            imperialUnit = actField.unit;
        }
        
        if (I_NEED_METRIC) {
            toConvert = metric;
            actField.tagFormat = [actField.tagFormat stringByReplacingOccurrencesOfString:actField.unit withString:metricUnit];
            //NSLog(@"METRIC VALUE      %i %@", metric.intValue, metricUnit);
        } else {
            toConvert = imperial;
            actField.tagFormat = [actField.tagFormat stringByReplacingOccurrencesOfString:actField.unit withString:imperialUnit];
            //NSLog(@"IMPERIAL VALUE    %i %@", imperial.intValue, imperialUnit);
        }
        
        if ([actField.unit isEqualToString:@"F"] && !I_NEED_FAHRENHEIT) { //convert to celsius
            toConvert = [toConvert convertFromUnit:actField.unit toUnit:actField.subUnit];
            actField.tagFormat = [actField.tagFormat stringByReplacingOccurrencesOfString:actField.unit withString:actField.subUnit];
            //NSLog(@"CELSIUS VALUE         %.f %@", toConvert.floatValue, actField.subUnit);
        } else {
            //NSLog(@"NOT TEMPERATURE ");
        }
        
        if (toConvert.floatValue < 1) {
            metadata = toConvert.floatValue == 0.0f ? @"0" : [NSString stringWithFormat:@"%.1f", toConvert.floatValue];
        } else {
            metadata = [NSString stringWithFormat:@"%.f", toConvert.floatValue];
        }
        
    }
    
    metadata = [actField.tagFormat stringByReplacingOccurrencesOfString:@"x" withString: metadata]; //replace tag format with value
    metadata = [metadata stringByReplacingOccurrencesOfString:@" " withString: @""]; //remove spaces
    
    [activityLabel setText:actField.displayName];
    [metadataTextField setText:metadata];
    metadataTextField.enabled = actField.editable ? YES : NO;
    
    //check if hash tag is on the array
    
    if ([privateHashTagKeys containsObject:actField.name]) {
        [shareButton setImage:[UIImage imageNamed:@"check-disabled.png"] forState:UIControlStateNormal];
    } else {
        [shareButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    }
    
    //check if editable
    if (actField.editable) {
        [lockButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    } else {
        [lockButton setImage:[UIImage imageNamed:@"lock-close.png"] forState:UIControlStateNormal];
    }
    
    //set the property of cell
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setActivityField:actField];
    
    //add target when checked tapped
    [shareButton addTarget:self action:@selector(checkedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - Hashtags

- (IBAction)checkedButtonTapped:(UIButton *)sender {
    GVMetadataCell *cell = (GVMetadataCell *)[[[sender superview] superview] superview];
    
    //for adding to hashtags array
    //UIButton *shareButton = (UIButton *)[cell viewWithTag:TAG_SHARE_BUTTON];
    
    //check if hash tag is on the array
    if ([privateHashTagKeys containsObject:cell.activityField.name]) {
        [sender setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        [privateHashTagKeys removeObject:cell.activityField.name];
    } else {
        [sender setImage:[UIImage imageNamed:@"check-disabled.png"] forState:UIControlStateNormal];
        [privateHashTagKeys addObject:cell.activityField.name];
    }
    
    NSLog(@">>> Private Hashtags: %@", privateHashTagKeys);
    NSLog(@"%@", enhancedMetadata);
}

//generate public hashtags

- (NSDictionary *)publicHashTags {
    NSMutableDictionary *htags = [NSMutableDictionary dictionary];
    
    NSString *key = [[NSString alloc] init];
    int ctr = 0;
    for (int i = 0;i < activityFieldsArray.count;i++) {
        GVActivityField *activity = (GVActivityField *)[activityFieldsArray objectAtIndex:i];
        
        //value
        NSString *data = (NSString *)[enhancedMetadata objectForKey:activity.name];
        NSString *metadata = data ? [NSString stringWithFormat:@"%@", data] : @"";
        metadata = [metadata stringByReplacingOccurrencesOfString:@" " withString:@""];
        metadata = [activity.tagFormat stringByReplacingOccurrencesOfString:@"#x" withString: metadata];
        
        if (![privateHashTagKeys containsObject:activity.name] && ![self.forbid containsObject:activity.name] && metadata.length) {
            
            //key
            key = [NSString stringWithFormat:@"hashTags[%i]", ctr];
            
            if (metadata.length) {
                [htags setObject:metadata forKey:key];
            }
            ctr++;
        }
    }
    return htags;
}

#pragma mark - set selected index to user

- (void)presentUserView
{
    NSArray *array = [(UITabBarController *)self.presentingViewController viewControllers];
    
    CameraViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];//(CameraViewController *)[[(UITabBarController *)self.presentingViewController viewControllers] objectAtIndex:1];
    
    [(UITabBarController *)self.presentingViewController setViewControllers:[NSArray arrayWithObjects: [array objectAtIndex:0], cvc,[array objectAtIndex:2], nil]];
    [(UITabBarController *)self.presentingViewController setSelectedIndex:0];
    
    [self.presentingViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [self.presentingViewController view];
}


#pragma mark - post photo details view

- (void)pushPhotoDetailsViewController {
   /* PhotoDetailsViewController *pdvc = (PhotoDetailsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PhotoDetailsViewController"];
    
    [Feed getLatestPhoto:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            Feed *latestFeed = (Feed *)[objects objectAtIndex:0];
            [pdvc setFeeds:@[latestFeed]];
            NSString *imageUrl = [NSString stringWithFormat:URL_IMAGE, latestFeed.imageFileName];
            NSString *caption = [NSString stringWithFormat:@"Gravitly %@ %@", latestFeed.caption, imageUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
#warning Uncomment posting to twitter and fb
                @try {
                    [self postToTwitter];
                    [self performSelector:@selector(postToFlickr:)];
                    [self performSelector:@selector(postToFacebook:)];
                }
                @catch (NSException *exception) {
                    NSLog(@"ERROR ON FACEBOOK OR TWITTER");
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud setLabelText:[NSString stringWithFormat:@"Upload success"]];
                    [hud removeFromSuperview];
                    [self.navigationController pushViewController:pdvc animated:YES];
                });
            });
        }
    }];*/
}

#pragma mark - SM Buttons

- (IBAction)postToGooglePlus:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //google sign in
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.clientID= kClientId;
        signIn.scopes= [NSArray arrayWithObjects:kGTLAuthScopePlusLogin, nil];
        signIn.shouldFetchGoogleUserID=YES;
        signIn.shouldFetchGoogleUserEmail=YES;
        signIn.delegate=self;
        signIn.attemptSSO = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [signIn authenticate];
        });
    });
    
}

-(void)postToFacebook: (id)sender {
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] && sma.facebookButton.tag == 1) {
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
                    [self performSelector:@selector(facebook)];
                }
            }];
        } else {
            [self performSelector:@selector(facebook)];
        }
    }
}

-(void)facebook
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:/*captionTextView.text*/ [self getCaptionHashTag] forKey:@"message"];
    [params setObject:UIImagePNGRepresentation(imageHolder) forKey:@"picture"];
    
    [FBRequestConnection startWithGraphPath:@"me/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
         if (error) {
             NSLog(@"FACEBOOK ERROR: %@", error.description);
         } else {
             NSLog(@"FACEBOOKED");
         }
    }];
}

-(void)postToTwitter
{
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] && sma.twitterButton.tag == 1) {
        SNSHelper *sns = [[SNSHelper alloc] init];
        [sns tweet:[self getCaptionHashTag] withImage:imageHolder block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"TWEETED");
            } else {
                NSLog(@"TWEET ERROR: %@", error.description);
            }
        }];
    } else {
        NSLog(@"NO TWITTER ACCOUNT LINKED!");
    }
}

- (void)postToFlickr: (id)button {
    //UIButton *sender = (UIButton *)button;
    
    //sender.enabled = NO;
    if ([GVFlickr isLinkedWithUser:[PFUser currentUser]] && sma.flickrButton.tag == 1) {
        GVFlickr *flickr = [[GVFlickr alloc] init];
        NSString *isPublic = [isPrivate isEqualToString:@"0"] ? @"1" : @"0";
        
        NSDictionary *dictionary = @{@"imageData": UIImageJPEGRepresentation(imageHolder, 1.0f),
                                     @"caption": /*captionTextView.text*/[self getCaptionHashTag],
                                     @"isPublic": isPublic,
                                     };
        [flickr uploadToFlickr:dictionary withBlock:^(BOOL succeed, NSError *error) {
            if (succeed) {
                NSLog(@"FLICKRED");
                #warning DO HUD
            } else {
                NSLog(@"FLICKR ERROR: %@", error.description);
            }
            //sender.enabled = YES;
        }];
    } else {
        NSLog(@"NO FLICKR ACCOUNT LINKED!");
        //sender.enabled = YES;
    }
}

#pragma mark - Google delegate methods

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (!error) {
        NSLog(@">>>>>>> GOOGLE AUTH DATA: %@", auth);
        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
        
        // Set any prefilled text that you might want to suggest
        [shareBuilder setPrefillText:captionTextView.text];
        [shareBuilder attachImage:imageHolder];
        [shareBuilder open];
    } else {
        NSLog(@">>>>>>> GOOGLE AUTH ERROR: %@", error.localizedDescription);
    }
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request
                                                                delegate:self];
    [connection start];
    return YES;
}

@end

