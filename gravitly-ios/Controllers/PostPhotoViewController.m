//
//  PostPhotoViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/10/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

//TODO:change url
//#define BASE_URL @"http://192.168.0.88:19001/" //local
#define BASE_URL @"http://webapi.webnuggets.cloudbees.net"
#define ENDPOINT_UPLOAD @"admin/upload"
#define TAG_LOCATION_NAV_BAR 201
#define TAG_LOCATION_TEXT 202
#define TAG_LOCATION_SUBMIT_BUTTON 203
#define TAG_ACTIVITY_LABEL 401
#define TAG_METADATA_LABEL 402
#define TAG_SHARE_BUTTON 403
#define ARRAY_ENHANCED_METADATA @[@"Location:", @"Location2:", @"Activity:", @"Wave Height:", @"Period:", @"Wind Dir:", @"Water Temp:"]

#import "PostPhotoViewController.h"
#import "GVHTTPClient.h"
#import <AFJSONRequestOperation.h>
#import <AFNetworkActivityIndicatorManager.h>
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

@interface PostPhotoViewController ()

@end

@implementation PostPhotoViewController {
    MBProgressHUD *hud;
    UIView *locationView;
    UINavigationBar *locationViewNavBar;
    UIButton *submitButton;
    MLPAutoCompleteTextField *autocompleteTextField;
    Metadata *enhancedMetadata;
    UIView *overlayView;
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
    placesApiLocations = [[NSMutableDictionary alloc] init];
    
    [self.navigationItem setTitle:@"Post"];
    [self setBackButton:navBar];
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
    
    //location view
    autocompleteTextField = [[MLPAutoCompleteTextField alloc] init];
    locationView = nil;
    
    
    overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [overlayView setBackgroundColor:[UIColor blackColor]];
    [overlayView setAlpha:0.5f];
    [metadataTableView setSeparatorColor:[GVColor grayColor]];
    [self.view addSubview:overlayView];
    [self showLocationView];
    [self setBackButton:locationViewNavBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)enhanceMetadataArray {
    return ARRAY_ENHANCED_METADATA;
}

#pragma mark - Location view

- (void)showLocationView {
    locationView = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"LocationView" owner:self options:nil] objectAtIndex:0];
    [locationView setAlpha:0];
    locationViewNavBar = (UINavigationBar *)[locationViewNavBar viewWithTag:TAG_LOCATION_NAV_BAR];
    
    
    
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
    static NSString *categoryKey = @"category";
    static NSString *locationKey = @"location";
    static NSString *isPrivateKey = @"isPrivate";
    //static NSString *hashTagKey = @"hashTags";
    
    NSLog(@"%@", selectedActivity.objectId);
    
    NSString *filename = @"temp.jpg";
    
    if (data) {
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                captionTextView.text, captionKey,
                                filename, filenameKey,
                                @"LsmI34VlUu", userKey,
                                selectedActivity.objectId, categoryKey,
                                @"hN3jostdcu", locationKey,
                                @"false", isPrivateKey,
                                enhancedMetadata.activity.tagName, @"hashTags[0]",
                                enhancedMetadata.location1, @"hashTags[1]",
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
            int percentage = ceil(((float)totalBytesWritten / (float)totalBytesExpectedToWrite ) * 100.0f);
            [hud setLabelText:[NSString stringWithFormat:@"Uploading %i %%", percentage]];
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self saveImageToLibraryWithMetadata:metadata];
            [self pushPhotoDetailsViewController];
            
            NSLog(@"Upload Success!");
            NSLog(@"string");
            
            
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

#pragma mark - MLPAutoCompleteTextField DataSource

//example of asynchronous fetch:
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
    NSLog(@"completion handler ..");
    if (string.length > 2) {
        NSString *catId = selectedActivity.objectId; //[[categoryDict allKeys] objectAtIndex:selectedRow];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(queue, ^{
            PFQuery *query = [PFQuery queryWithClassName:@"Location"];
            [query whereKey:@"name" containsString:string];
            [query whereKey:@"categories" equalTo:catId];
            
            NSLog(@">>>>>>>>>>>>>>>> %@ %i", catId, [query countObjects]);
            
            
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

#pragma mark - MLPAutoCompleteTextField Delegate

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
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationDelegate:self];
    CGRect lastFrame = locationView.frame;
    locationView.frame = CGRectMake(lastFrame.origin.x, lastFrame.origin.y, lastFrame.size.width, lastFrame.size.height + 110.0f);
    lastFrame = submitButton.frame;
    submitButton.frame = CGRectMake(lastFrame.origin.x, lastFrame.origin.y + 110.0f, lastFrame.size.width, lastFrame.size.height);
    [UIView commitAnimations];
    
    [self slideFrame:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationDelegate:self];
    CGRect lastFrame = locationView.frame;
    locationView.frame = CGRectMake(lastFrame.origin.x, lastFrame.origin.y, lastFrame.size.width, lastFrame.size.height - 110.0f);
    lastFrame = submitButton.frame;
    submitButton.frame = CGRectMake(lastFrame.origin.x, lastFrame.origin.y  - 110.0f, lastFrame.size.width, lastFrame.size.height);
    [UIView commitAnimations];
    
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

#pragma mark - Add Location Button

-(IBAction)submit:(id)sender
{
    NSLog(@"Submitting..");
    [self performSelector:@selector(saveLocationOnParse) withObject:nil];
}

static bool newLocation = FALSE;

-(void)saveLocationOnParse
{
    if (newLocation)
    {
        NSString *name = autocompleteTextField.text;
        NSString *gpRef = [placesApiLocations valueForKey:name];
        
        if (gpRef)
        {
            NSString *catId = selectedActivity.objectId;
            PFObject *newloc = [PFObject objectWithClassName:@"Location"];
            [newloc setObject:name forKey:@"name"];
            [newloc setObject:gpRef forKey:@"googRef"];
            [newloc setObject:[NSArray arrayWithObjects:catId, nil] forKey:@"categories"];
            [newloc saveInBackground];
        }
    }
    newLocation = FALSE;
    [self retrieveEnhancedMetadata];
}


-(void)retrieveEnhancedMetadata {
    //gps
    [locationManager startUpdatingLocation];
    
    NSString *name = autocompleteTextField.text;
    NSString *gpRef = [placesApiLocations valueForKey:name];
    NSString *catId = selectedActivity.objectId;
    
    NSString *urlString = [NSString stringWithFormat:@"http://webapi.webnuggets.cloudbees.net/meta/%@/%@/%f,%f", catId, gpRef, lastLocation.coordinate.latitude, lastLocation.coordinate.longitude];
    
    NSLog(@"url>>> %@", urlString);
    
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:urlString]];
    
    [client getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@">>>>> response %@", operation.responseString);
        
        
        NSError *error = nil;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        NSDictionary *jsonDict = [jsonData valueForKeyPath:selectedActivity.name];
        enhancedMetadata = [[Metadata alloc] init];
        enhancedMetadata.location1 = [jsonDict objectForKey:@"name"];
        enhancedMetadata.location2 = [jsonDict objectForKey:@"locality"];
        enhancedMetadata.waterTempC = [jsonDict objectForKey:@"temp_C"];
        enhancedMetadata.waterTempF = [jsonDict objectForKey:@"temp_F"];
        enhancedMetadata.activity = selectedActivity;
        
        [self hideLocationAndOverlayView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void) hideLocationAndOverlayView {
    [overlayView removeFromSuperview];
    [locationView removeFromSuperview];
    [metadataTableView reloadData];
}

#pragma mark - Table View delegate and datasource


- (void)customiseFields: (UITableView *)tableView {
    [self customiseTable:tableView];
    [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 224.0f)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self enhanceMetadataArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"MetadataCell" owner:self options:nil];
        cell = (UITableViewCell *)[nibs objectAtIndex:0];
    }
    
    GVLabel *activityLabel = (GVLabel *)[cell viewWithTag:TAG_ACTIVITY_LABEL];
    [activityLabel setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize16];
    GVLabel *metadataLabel = (GVLabel *)[cell viewWithTag:TAG_METADATA_LABEL];
    [metadataLabel setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize16];
    UIButton *shareButton = (UIButton *)[cell viewWithTag:TAG_SHARE_BUTTON];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [activityLabel setText:[[self enhanceMetadataArray] objectAtIndex:indexPath.row]];
    
    
    NSString *data = [[NSString alloc] init];
    
    switch (indexPath.row) {
        case 0:
            [metadataLabel setText:[NSString stringWithFormat:@"#%@", enhancedMetadata.location1]];
            break;
        case 1:
            [metadataLabel setText:[NSString stringWithFormat:@"#%@", enhancedMetadata.location2]];
            break;
        case 2:
            [metadataLabel setText:[NSString stringWithFormat:@"#%@", enhancedMetadata.activity.name]];
            break;
        case 3:
            if (enhancedMetadata.waveHeight != nil) {
                [metadataLabel setText:[NSString stringWithFormat:@"#%@", enhancedMetadata.waveHeight]];
            }
            break;
        case 4:
            if (enhancedMetadata.period != nil) {
                [metadataLabel setText:[NSString stringWithFormat:@"#%@", enhancedMetadata.period]];
            }
            break;
        case 5:
            [metadataLabel setText:[NSString stringWithFormat:@"#%.2f", enhancedMetadata.windDirection]];
            break;
        case 6:
            [metadataLabel setText:[NSString stringWithFormat:@"#%@F", enhancedMetadata.waterTempF]];
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - post photo details view

- (void)pushPhotoDetailsViewController {
    PhotoDetailsViewController *pdvc = (PhotoDetailsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PhotoDetailsViewController"];
    
    [Feed getLatestPhoto:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            Feed *latestFeed = (Feed *)[objects objectAtIndex:0];
            [pdvc setFeeds:@[latestFeed]];
            [self.navigationController pushViewController:pdvc animated:YES];
            [hud setLabelText:[NSString stringWithFormat:@"Upload success"]];
            [hud removeFromSuperview];
        }
    }];
}

@end
