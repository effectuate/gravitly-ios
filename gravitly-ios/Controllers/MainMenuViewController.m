//
//  MainMenuViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "MainMenuViewController.h"
#import "CropPhotoViewController.h"
#import "LogInViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking.h>

@interface MainMenuViewController ()

@property (nonatomic) UIImage *capturedImaged;
@property (nonatomic) UIImagePickerController *picker;

@end

@implementation MainMenuViewController 

/*@synthesize overlayView;
@synthesize cropperView;*/

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
    [self getLatestPhotoFromGallery];
    //check if phone has camera.. do i need this? --pugs
    /*
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Device has no camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [myAlertView show];
    }
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnTakePhoto:(id)sender {
    /*TODO:delete
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = NO;
    
    
    [[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil];
    self.overlayView.frame = picker.cameraOverlayView.frame;
    picker.cameraOverlayView = self.overlayView;
    self.overlayView = nil;
    self.picker = picker;
    //[self.navigationController pushViewController:picker animated:YES];
     [self presentViewController:picker animated:YES completion:nil];*/
}

- (IBAction)btnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)btnGrabIt:(id)sender {
    NSLog(@"taking picture...");
    [self.picker takePicture];
}

- (IBAction)btnCameraRoll:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker = picker;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)btnGallery:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker = picker;
    
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)btnLogout:(id)sender {
    LogInViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
    [self presentViewController:lvc animated:YES completion:nil];
    
    //[self presentViewController:lvc animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    /*NSLog(@"taking picture --->");
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    
    CALayer *layer = [CALayer layer];
    layer.frame = cropperView.frame;    
    
    
    self.capturedImaged = image;
    [self finishAndUpdate];*/
}


-(void) finishAndUpdate {
    /*[self dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"todo.. go to cropping and filter page now..");
    CropPhotoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CropPhoto"];
    vc.imageHolder = self.capturedImaged;
    [self.navigationController pushViewController:vc animated:YES];*/
}

- (void)getLatestPhotoFromGallery {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // be sure to filter the group so you only get photos
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                ALAssetRepresentation *repr = [result defaultRepresentation];
                UIImage *img = [UIImage imageWithCGImage:[repr fullResolutionImage]];
                NSLog(@"---------------> getting latest image %@", img);
                
                *stop = YES;
            }
        }];
        *stop = NO;
        
     
    } failureBlock:^(NSError *error) {
        NSLog(@"fail *error");
    }];
}


- (IBAction)btnDeleteMe:(id)sender {
    /*NSURL *url = [NSURL URLWithString:@"http://www.flickr.com"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *endpoint = @"/services/oauth/request_token";
    
    static NSString *oauthNonceParam = @"oauth_nonce";
    static NSString *oauthTimestampParam = @"oauth_timestamp";
    static NSString *oauthConsumerKeyParam = @"oauth_consumer_key";
    static NSString *oauthSignatureMethodParam = @"oauth_signature_method";
    static NSString *oauthVersionParam = @"oauth_version";
    static NSString *oauthCallbackParam = @"oauth_callback";
    
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString* oauthNonce =  (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    NSString *oauthTimestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSLog(@"%@ %@", oauthNonce, oauthTimestamp);
    NSString *oauthConsumerKey = @"a76acd646df6b630994700af01969f78";
    NSString *oauthSignatureMethod = @"HMAC-SHA1";
    NSString *oauthVersion = @"1.0";
    NSString *oauthCallback = [@"http://www.google.com" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            oauthNonce, oauthNonceParam,
                            oauthTimestamp, oauthTimestampParam,
                            oauthConsumerKey, oauthConsumerKeyParam,
                            oauthSignatureMethod, oauthSignatureMethodParam,
                            oauthVersion, oauthVersionParam,
                            oauthCallback, oauthCallbackParam,
                            nil];
     */
    
    /*NSURL *url = [NSURL URLWithString:@"http://www.flickr.com"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *endpoint = @"/auth-72157636112377046";
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    
    [client getPath:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure %@", error.description);
    }];*/
    
    
    

}

@end
