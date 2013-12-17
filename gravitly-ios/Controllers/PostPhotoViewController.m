    //
//  PostPhotoViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/10/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

//TODO:change url
//#define BASE_URL @"http://192.168.0.128:8080/" //local
//#define BASE_URL @"http://192.168.0.100:19001/" //local

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

#define FORBID_FIELDS_ARRAY @[@"community", @"region", @"country", @"Elevation M", @"Elevation F"]
#define ADDITIONAL_FIELDS_ARRAY @[@"Tag"]
#define IS_LITE 1


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
    NSLog(@">>>>>>>>> WILLLLAPPPEAR");
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"frob"]) {
        GVFlickr *flickr = [[GVFlickr alloc] init];
        [flickr getAuthTokenWithFrob:[[NSUserDefaults standardUserDefaults] objectForKey:@"frob"]];
    }
}
-(void)viewDidAppear:(BOOL)animated {
    NSLog(@">>>>>>>>> DID APPEAR");
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
    
    
    SocialMediaAccountsController *sma = [self smaView:@"Share to:"];
    [sma setFrame:CGRectMake(sma.frame.origin.x, sma.frame.origin.y + 10, sma.frame.size.width, sma.frame.size.height)];
    [sma setBackgroundColor:[GVColor backgroundDarkColor]];
    [sma.facebookButton addTarget:self action:@selector(postToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [sma.twitterButton addTarget:self action:@selector(postToTwitter:) forControlEvents:UIControlEventTouchUpInside];
    [sma.googlePlusButton addTarget:self action:@selector(postToGooglePlus:) forControlEvents:UIControlEventTouchUpInside];
    [sma.flickrButton addTarget:self action:@selector(postToFlickr:) forControlEvents:UIControlEventTouchUpInside];
    
    [smaView addSubview:sma];
    
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

    
}

- (NSArray *)forbid {
    return (NSArray *)FORBID_FIELDS_ARRAY;
}

- (NSArray *)additional {
    return (NSArray *)ADDITIONAL_FIELDS_ARRAY;
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
        [enhancedMetadata setObject:@"" forKey: key];
        GVActivityField *actField = [[GVActivityField alloc] init];
        actField.name = key;
        if ([act isEqualToString:@"Tag"]) {
            actField.tagFormat = @"@gravitly";
            actField.editable = 0;
            [activityFieldsArray addObject:actField];
        } else {
            actField.tagFormat = @"#x";
            actField.editable = 1;
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
    [self.view addSubview:captionViewPlaceholder];
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
                //[self pushPhotoDetailsViewController];
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
    
    if ([[newText substringToIndex:1] isEqualToString:@"#"]) {
        newText = [textField.text stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:@""];
    }
    
    [enhancedMetadata setObject:newText forKey:actField.name];
    
    //location name
    if ([actField.name.description
         isEqualToString:@"Named Location"]) {
        if ([[newText substringToIndex:1] isEqualToString:@"#"]) {
            newText = [textField.text stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:@""];
        }
        locationName = newText;
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
    
    UITextField *metadataTextField = cell.metadataTextfield;
    [metadataTextField setTag:indexPath.row];
    [metadataTextField setDelegate:self];
    
    //retrieval and replacing of values from tag format
    NSString *data = [enhancedMetadata objectForKey:actField.name];
    
    NSString *metadata = data ? [NSString stringWithFormat:@"%@", data] : @"";
    metadata = [actField.tagFormat stringByReplacingOccurrencesOfString:@"x" withString: metadata];

    [activityLabel setText:actField.name];
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
    
    CameraViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    
    [(UITabBarController *)self.presentingViewController setViewControllers:[NSArray arrayWithObjects: [array objectAtIndex:0], cvc,[array objectAtIndex:2], nil]];
    [(UITabBarController *)self.presentingViewController setSelectedIndex:0];
    
    [self.presentingViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [self.presentingViewController view];
}


#pragma mark - post photo details view

- (void)pushPhotoDetailsViewController {
    PhotoDetailsViewController *pdvc = (PhotoDetailsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PhotoDetailsViewController"];
    
    [Feed getLatestPhoto:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            Feed *latestFeed = (Feed *)[objects objectAtIndex:0];
            [pdvc setFeeds:@[latestFeed]];
            NSString *imageUrl = [NSString stringWithFormat:URL_IMAGE, latestFeed.imageFileName];
            NSString *caption = [NSString stringWithFormat:@"Gravitly %@ %@", latestFeed.caption, imageUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
#warning Uncomment posting to twitter and fb
                @try {
                    [self postToTwitter:caption];
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
    }];
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

-(void)postToFacebook: (UIButton *)sender {
    
    MBProgressHUD *hudw = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hudw setLabelText:@"Posting to Facebook..."];
    if (!FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            NSLog(@"PUGS 3");
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
                [params setObject:captionTextView.text forKey:@"message"];
                [params setObject:UIImagePNGRepresentation(imageHolder) forKey:@"picture"];
                //sender.enabled = NO; //for not allowing multiple hits
                
                [FBRequestConnection startWithGraphPath:@"me/photos"
                                             parameters:params
                                             HTTPMethod:@"POST"
                                      completionHandler:^(FBRequestConnection *connection,
                                                          id result,
                                                          NSError *error)
                 {
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
                     //sender.enabled = YES;
                 }];
            }
        }];
    } else {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setObject:captionTextView.text forKey:@"message"];
        [params setObject:UIImagePNGRepresentation(imageHolder) forKey:@"picture"];
        //sender.enabled = NO; //for not allowing multiple hits
        
        [FBRequestConnection startWithGraphPath:@"me/photos"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error)
         {
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
             //sender.enabled = YES;
         }];
        
    }
}

-(void)postToTwitter: (NSString *)caption;
{
    NSLog(@"twwett tweet");
    
    [self addTwitterUserToIphoneStoreAccount];
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil
                                  completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             //get the twitter account of the parse user
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             ACAccount *twitterAccount;
             
             NSString *twitterUserid = [PFTwitterUtils twitter].screenName;
             NSLog(@"users link twitter id: %@", twitterUserid);
             
             for (ACAccount *account in arrayOfAccounts) {
                 NSLog(@"Username: %@", account.username);
                 if ([account.username isEqualToString:twitterUserid]) {
                     twitterAccount = account;
                 }
             }
             
             NSDictionary *message = @{@"status": caption};
             
             NSURL *requestURL = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
             
             SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodPOST
                                                                   URL:requestURL
                                                            parameters:message];
             
             postRequest.account = twitterAccount;
             
             [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
                  NSLog(@"Twitter HTTP response: %i %@", [urlResponse statusCode], error.localizedDescription);
             }];
         }
     }];
}

-(void) addTwitterUserToIphoneStoreAccount {
    //init account store
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    
    //get the tokens from the user's link twitter account
    NSString *token = [[PFTwitterUtils twitter] authToken];
    NSString *secret = [[PFTwitterUtils twitter] authTokenSecret];
    ACAccountCredential *credential = [[ACAccountCredential alloc] initWithOAuthToken:token tokenSecret:secret];
    
    //Attach the credential for this user
    ACAccount *newAccount = [[ACAccount alloc] initWithAccountType:accountType];
    newAccount.credential = credential;
    
    //check if this user is already added in account store for twitter
    NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
    
    NSString *twitterUserid = [PFTwitterUtils twitter].screenName;
    NSLog(@"users link twitter id: %@", twitterUserid);
    
    int ctr = 0;
    for (ACAccount *account in arrayOfAccounts) {
        NSLog(@"Username: %@", account.username);
        if ([account.username isEqualToString:twitterUserid]) {
            ctr++;
        }
    }
    
    if (ctr == 0) {
        //add the account in the phone
        [account saveAccount:newAccount withCompletionHandler:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"user added to accounts");
            }
        }];
    } else {
        NSLog(@"this user has already this account on his phone");
    }
}

- (void)postToFlickr: (UIButton *)sender {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FLICKR_AUTH_TOKEN"]) {
        GVFlickr *flickr = [[GVFlickr alloc] init];
        NSString *isPublic = [isPrivate isEqualToString:@"0"] ? @"1" : @"0";
    
        NSDictionary *dictionary = @{@"imageData": UIImageJPEGRepresentation(imageHolder, 1.0f),
                                     @"caption": captionTextView.text,
                                     @"isPublic": isPublic,
                                     }; 
        [flickr uploadToFlickr:dictionary];
    } else {
        NSLog(@"NO FLICKR AUTH TOKEN");
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


#pragma mark - ObjectiveFlickr

//NSString *kStoredAuthTokenKeyName = @"FlickrOAuthToken";
//NSString *kStoredAuthTokenSecretKeyName = @"FlickrOAuthTokenSecret";

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//    if ([connection.currentRequest.URL.description isEqualToString:@"http://m.flickr.com/#/services/auth/"]) {
//        NSLog(@"REPSOERPONDFFSKl >>>>>>>>>>> %@", response);
//    } else {
//        NSLog(@"Response: %u (%@)", [httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
//        NSLog(@"NEGATIVITY >>>>>>>>>>> %@", response);
//    }

}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"-----> FAIL");
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //http://www.flickr.com/services/rest/?method=flickr.auth.getFullToken&api_key=97098faab7af82062b86085f05d0aa1c&mini_token=757692816
    
    //if ([request.URL.description isEqualToString:@"http://m.flickr.com/#/services/auth/"]) {
//        NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:request.URL
//                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                           timeoutInterval:60.0];
        
        NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request
                                                                     delegate:self];
        [connection start];
        
    //}
    return YES;
}

@end

//api_sig=47dd78628af1eedbcd9199370cdbcc8c
//api_key=97098faab7af82062b86085f05d0aa1c
//mini_token=866-566-508
//format=rest
//auth_token=72157637687365916-55289337f2d327db


//http://www.flickr.com/services/rest/?method=flickr.auth.getFullToken&api_key=97098faab7af82062b86085f05d0aa1c&api_sig=47dd78628af1eedbcd9199370cdbcc8c&mini_token=290-587-226

//http://api.flickr.com/services/rest/?
//method=flickr.auth.getFullToken&api_key=97098faab7af82062b86085f05d0aa1c&mini_token=866-566-508&format=rest&auth_token=72157637687365916-55289337f2d327db&api_sig=47dd78628af1eedbcd9199370cdbcc8c


