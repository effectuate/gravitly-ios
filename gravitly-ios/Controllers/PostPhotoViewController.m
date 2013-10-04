//
//  PostPhotoViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/10/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

//TODO:change url
//#define BASE_URL @"http://192.168.0.124:19000/" //local
#define BASE_URL @"http://webapi.webnuggets.cloudbees.net" 
#define ENDPOINT_UPLOAD @"admin/upload"

#import "PostPhotoViewController.h"
#import "AddActivityViewController.h"
#import "GVHTTPClient.h"
#import <AFJSONRequestOperation.h>
#import <AFNetworkActivityIndicatorManager.h>
#import <MBProgressHUD.h>
#import "SNSHelper.h"
#import <Parse/Parse.h>
#import "UTF8Helper.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/CGImageProperties.h>


@interface PostPhotoViewController ()

@end

@implementation PostPhotoViewController {
    MBProgressHUD *hud;
}

@synthesize imageHolder;
@synthesize thumbnailImageView;
@synthesize captionTextView;
@synthesize smaView;
@synthesize activityButton;
@synthesize enhancementsButton;
@synthesize navBar;
@synthesize locationManager;

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
    [self.navigationItem setTitle:@"Post"];
    [self setBackButton];
    [self setRightBarButtons];
    [self.captionTextView setText:@"Add Caption"];
    //[self.captionTextView setDelegate:self];
    SocialMediaAccountsController *sma = [self smaView:@"Share to:"];
    [sma setBackgroundColor:[GVColor backgroundDarkColor]];
    [sma.facebookButton addTarget:self action:@selector(postToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [sma.twitterButton addTarget:self action:@selector(postToTwitter:) forControlEvents:UIControlEventTouchUpInside];
    [smaView addSubview:sma];   
	[self.thumbnailImageView setImage: self.imageHolder];
    captionTextView.delegate = self;
    snsDelegate = [[SNSHelper alloc] init];
    
    //location
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextView methods for placeholder

/*- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    captionTextView.text = @"";
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(captionTextView.text.length == 0){
        captionTextView.textColor = [UIColor lightGrayColor];
        captionTextView.text = @"shit";
        [captionTextView resignFirstResponder];
    }
}*/

#pragma mark - Nav buttons

- (void)setBackButton
{
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    navBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)setRightBarButtons {
    UIButton *lockButton = [self createButtonWithImageNamed:@"lock.png"];
    [lockButton addTarget:self action:@selector(lockTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *proceedButton = [self createButtonWithImageNamed:@"check-big.png"];
    [proceedButton addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *buttons = @[[[UIBarButtonItem alloc] initWithCustomView:proceedButton], [[UIBarButtonItem alloc] initWithCustomView:lockButton]];
    
    navBar.topItem.rightBarButtonItems = buttons;
}

-(IBAction)lockTapped:(id)sender {
    NSLog(@"tinap mo ung lock");
}

-(void)upload {
    
    
    //sources: https://raw.github.com/sburel/cordova-ios-1/cc8956342b2ce2fafa93d1167be201b5b108d293/CordovaLib/Classes/CDVCamera.m
    // https://github.com/lorinbeer/cordova-ios/pull/1/files
    
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    //[metadata setObject:@"caption" forKey:@"txtCaption"];
    
    NSMutableDictionary *tiffMetadata = [[NSMutableDictionary alloc] init];
    [tiffMetadata setObject:@"This is my description" forKey:(NSString*)kCGImagePropertyTIFFImageDescription];
    
    [metadata setObject:tiffMetadata forKey:(NSString*)kCGImagePropertyTIFFDictionary];
    
    //gps
    [locationManager startUpdatingLocation];
    
    NSMutableDictionary *GPSDictionary = [[NSMutableDictionary alloc] init];
    CLLocation *newLocation = locationManager.location;
    
    CLLocationDegrees latitude  = newLocation.coordinate.latitude;
    CLLocationDegrees longitude = newLocation.coordinate.longitude;
    
    NSLog(@"%f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
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
    
    
    [metadata setObject:GPSDictionary forKey:(NSString*)kCGImagePropertyGPSDictionary];
    
    
    NSURL *url = [NSURL URLWithString:BASE_URL];
    NSData *data = UIImageJPEGRepresentation(imageHolder, 1.0);
    
    static NSString *imageKey = @"image";
    static NSString *captionKey = @"caption";
    static NSString *filenameKey = @"filename";
    static NSString *userKey = @"userKey";
    static NSString *categoryIdKey = @"category"; //@"categoryId";
    static NSString *locationIdKey = @"location"; //@"locationId";
    static NSString *isPrivateKey = @"isPrivate";
    //static NSString *hashTagKey = @"hashTags";
    
    NSString *user = @"LsmI34VlUu"; //TODO:[PFUser currentUser].objectId;
    NSString *filename = @"temp.jpg";
    
    if (data) {
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                captionTextView.text, captionKey,
                                filename, filenameKey,
                                @"LsmI34VlUu", userKey,
                                @"uoabsxZmSB", categoryIdKey,
                                @"u6ffhvdZJH", locationIdKey,
                                @"true", isPrivateKey,
                                [NSString stringWithFormat:@"%f", latitude], @"latitude",
                                [NSString stringWithFormat:@"%f", longitude], @"longitude",
                                /*@"snow, snow_country", hashTagKey*/
                                nil];
        
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:url];
        //[client clearAuthorizationHeader];
        //[client setAuthorizationHeaderWithUsername:@"kingslayer07" password:@"password"];
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:ENDPOINT_UPLOAD parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:imageKey fileName:filename mimeType:@"image/jpeg"];
        }];
    
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setLabelText:[NSString stringWithFormat:@"Uploading"]];
        
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            int percentage = ceil(((float)totalBytesWrzitten / (float)totalBytesExpectedToWrite ) * 100.0f);
            [hud setLabelText:[NSString stringWithFormat:@"Uploading %i %%", percentage]];
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self saveImageToLibraryWithMetadata:metadata];
            [hud setLabelText:[NSString stringWithFormat:@"Upload success"]];
            [hud removeFromSuperview];
            [self presentTabBarController:self];
            
            NSLog(@"Upload Success!");
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

- (void)saveImageToLibraryWithMetadata:(NSMutableDictionary *)metadata {
    //add metadata here + save to photo album..
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    //UIImageWriteToSavedPhotosAlbum(imageView.image, nil, nil, nil);
    [library writeImageToSavedPhotosAlbum:self.thumbnailImageView.image.CGImage
                                 metadata:metadata
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              if (error == nil) {
                                  NSLog(@"saved");
                              } else {
                                  NSLog(@"error");
                              }
                          }];
    //
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    NSLog(@">>>>>>>>>>>>> updating location");
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
        //[locDict setObject:[self getUTCFormattedDate:location.timestamp] forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Add Caption"]) {
        textView.text = @"";
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Add Caption";
    }
    [textView resignFirstResponder];
}

- (IBAction)tweet:(id)sender {
    PFUser *user = [PFUser currentUser];
    if (![PFTwitterUtils isLinkedWithUser:user]) {
        
        [PFTwitterUtils linkUser:user];
        /*[PFTwitterUtils linkUser:user block:^(BOOL succeeded, NSError *error) {
            if ([PFTwitterUtils isLinkedWithUser:user]) {
                //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
                //hud.mode = MBProgressHUDModeText;
                //hud.labelText = @"Twitter Account Linked!";
                //[self performSelector:@selector(hideHUD) withObject:nil afterDelay:2.0];
            }
            NSLog(@"wahehehe %@", [PFUser currentUser]);
        }];*/
        
    } else {
        /*[self tweetBird:captionTextView.text withImage:imageHolder block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                NSLog(@"error %@", error.description);
            }
        }];*/
    //[self signFlickrRequest: (UIButton *)sender];
    }
}

-(void)postToTwitter: (UIButton *)sender {
    
    /*[self tweetBird:@"" withImage:imageHolder block:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"error po %@", error.description);
        }
    }];*/
}


-(void)postToFacebook: (UIButton *)sender {
    MBProgressHUD *hudw = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hudw setLabelText:@"Posting to Facebook..."];
    
    if (!FBSession.activeSession.isOpen) {
        NSLog(@"%d", !(FBSession.activeSession.isOpen));
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
                NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
                [params setObject:captionTextView.text forKey:@"message"];
                [params setObject:UIImagePNGRepresentation(imageHolder) forKey:@"picture"];
                sender.enabled = NO; //for not allowing multiple hits
                
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
                     sender.enabled = YES;
                 }];
            }
            
        }];
    }
}



-(void)tweetBird:(NSString *)text withImage:(UIImage *)image block:(BooleanResultBlock)block {
    // encode tweet
    //UTF8Helper *helper = [[UTF8Helper alloc] init];
    //NSString *bodyString = [helper convertStringToUTF8Encoding:text WithFormat:@"status="];
    
    NSString *boundary = @"----14737809831466499882746641449";
    
    NSURL *url = [NSURL URLWithString:@"https://upload.twitter.com/1.1/statuses/update_with_media.json"];
    NSMutableURLRequest *tweetRequest = [NSMutableURLRequest requestWithURL:url];
    [tweetRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [tweetRequest setHTTPShouldHandleCookies:NO];
    [tweetRequest setTimeoutInterval:30];
    [tweetRequest setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    //auth
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *consumerKey = @"rp7eWytARqeh53NkrZSLw";
    NSString *nonce = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));;
    NSString *signature = @"adsf";
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *token = @"40437216-AmWrMm5TgREjaCZkxzFj7bwELNcURNwpAeEu6Wm4";
    
    NSString *authorization = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"%@\", oauth_token=\"%@\", oauth_version=\"1.0\"", consumerKey, signature, nonce, timestamp, token];
    [tweetRequest setValue:authorization forHTTPHeaderField: @"Authorization"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [tweetRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    //[body appendData:[[NSString stringWithFormat:@"Content-type: multipart/form-data, boundary=%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"status\"\r\r"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"statustweetupdate\r"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media[]\"\r"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //[body appendData:[@"Content-Transfer-Encoding: binary\r\r" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *myString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    NSLog(@"\n%@", myString);
    
    [body appendData:imageData];
    
    NSString *asdf = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    NSLog(@"\n%@", asdf);
    
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [tweetRequest setHTTPBody:body];
    
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [tweetRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [[PFTwitterUtils twitter] signRequest:tweetRequest];
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    // Post status synchronously.
    [NSURLConnection sendSynchronousRequest:tweetRequest returningResponse:&response error:&error];
    
    block(!error, error);
    
}




@end
