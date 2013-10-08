//
//  CameraViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define TAG_CAMERA_OVERLAY_NAVBAR 100
#define TAG_CAMERA_OVERLAY_GRID_IMAGE_VIEW 101
#define TAG_CAMERA_OVERLAY_ZOOM_SLIDER 102
#define ZOOM_INTERVAL 0.20f

#import "CameraViewController.h"
#import "CropPhotoViewController.h"
#import "FilterViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD.h>

@interface CameraViewController ()

@end

@implementation CameraViewController {
    AppDelegate *appDelegate;
    float zoomScale;
    BOOL isCameraRearView;
    BOOL isGridVisible;
    BOOL isFlashOn;
    UIImageView *gridImageView;
    int delay;
    MBProgressHUD *hud;
    BOOL isPickerDismissed;
}

@synthesize cropperView;
@synthesize overlayView;
@synthesize capturedImaged;
@synthesize picker;
@synthesize capturedImageView;
@synthesize cameraGridImageView;
@synthesize zoomSliderObject;

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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.capturedImage = [[NSCache alloc] init];
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    zoomScale = 1.0f;
    isCameraRearView = YES;
    isGridVisible = NO;
    isFlashOn = NO;
    delay = 0;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (![[appDelegate.capturedImage objectForKey:@"capturedImage"] length] && !isPickerDismissed) {
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = NO;
        
        //set which camera to use rear or front
        //source: http://stackoverflow.com/questions/3669214/set-front-facing-camera-in-iphone-sdk
        
        UIView *cameraOverlayView = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil] objectAtIndex:0];
        UINavigationBar *navBar = (UINavigationBar *)[cameraOverlayView viewWithTag:TAG_CAMERA_OVERLAY_NAVBAR];
        [self setNavigationBar:navBar title:@"Camera" length:140.0f];
        UISlider *slider = (UISlider *)[cameraOverlayView viewWithTag:TAG_CAMERA_OVERLAY_ZOOM_SLIDER];
        [self customiseSlider:slider];
        gridImageView = (UIImageView *)[cameraOverlayView viewWithTag:TAG_CAMERA_OVERLAY_GRID_IMAGE_VIEW];
        [self setRightBarButtons:navBar];
        [self setBackButton:navBar];
        
        self.overlayView.frame = picker.cameraOverlayView.frame;
        
        picker.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
        self.picker = picker;
        
        [self presentViewController:picker animated:NO completion:nil];
        isPickerDismissed = NO;
    } else {
        [((UITabBarController *)(self.parentViewController))setSelectedIndex:0];
        isPickerDismissed = NO;
    } //for back button
}

- (void)pushPhotoFilterer {
    [hud removeFromSuperview];
    FilterViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];
    [fvc setImageHolder:self.capturedImaged];
    [fvc setZoomScale:zoomScale];
    [picker pushViewController:fvc animated:YES];
}

- (void)pushPhotoCropper {
    [hud removeFromSuperview];
    CropPhotoViewController *cpvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CropPhotoViewController"];
    [cpvc setImageHolder:self.capturedImaged];
    [picker pushViewController:cpvc animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Nav buttons

- (void)setRightBarButtons: (UINavigationBar *) navbar {
    
    UIButton *flashButton = [self createButtonWithImageNamed:@"flash.png"];
    [flashButton addTarget:self action:@selector(setFlashSettings) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *frontCameraButton = [self createButtonWithImageNamed:@"refresh.png"];
    [frontCameraButton addTarget:self action:   @selector(setCameraViewSettings) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *gridButton = [self createButtonWithImageNamed:@"grid.png"];
    [gridButton addTarget:self action:@selector(setGridSettings) forControlEvents:UIControlEventTouchUpInside];
    
    //TODO:delete
    UIButton *checkButton = [self createButtonWithImageNamed:@"check-big.png"];
    [checkButton addTarget:self action:@selector(setDelay) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *buttons = @[[[UIBarButtonItem alloc] initWithCustomView:flashButton], [[UIBarButtonItem alloc] initWithCustomView:frontCameraButton], [[UIBarButtonItem alloc] initWithCustomView:gridButton], [[UIBarButtonItem alloc] initWithCustomView:checkButton]];
    
    navbar.topItem.rightBarButtonItems = buttons;
}

- (void)backButtonTapped:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    //
    //[self dismissViewControllerAnimated:YES completion:nil];
    isPickerDismissed = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    //[appDelegate.capturedImage setObject:nil forKey:@"capturedImage"];
    [((UITabBarController *)(self.parentViewController))setSelectedIndex:0];
}


#pragma mark - Image Picker delegates

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"cancel can you hear me?");
    //[self.navigationController popViewControllerAnimated:YES];
    
    //todo.. still having error w/ this one. weird..
    CameraViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    [picker pushViewController:fvc animated:YES];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.capturedImaged = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"info of image %@", info);
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            double ratio;
            double delta;
            CGPoint offset;
            
            //make a new square size, that is the resized imaged width
            
            CGSize newSize = CGSizeMake(/*cropperView.frame.size.width*/ 612.0f * zoomScale, /*cropperView.frame.size.width*/ 612.0f * zoomScale);
            
            CGSize sz = CGSizeMake(newSize.width, newSize.width);
            
            UIImage *image = self.capturedImaged;
            
            //figure out if the picture is landscape or portrait, then
            //calculate scale factor and offset
            
            if (image.size.width > image.size.height) {
                ratio = newSize.width / image.size.width;
                delta = (ratio*image.size.width - ratio*image.size.height);
                offset = CGPointMake(delta/2, 0);
            } else {
                ratio = newSize.width / image.size.height;
                delta = (ratio*image.size.height - ratio*image.size.width);
                offset = CGPointMake(0, delta/2);
            }
            
            
            //make the final clipping rect based on the calculated values
            
            //float *imgWidth = zoomScale > 1.0f : image.size.width * zoomScale
            //float *imgHeigth =
            
            CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                         (ratio * (image.size.width )) + delta,
                                         (ratio * (image.size.height)) + delta);
            
            //start a new context, with scale factor 0.0 so retina displays get
            //high quality image
            //if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                UIGraphicsBeginImageContextWithOptions(sz, NO, 0.0);
            /*} else {
                UIGraphicsBeginImageContext(sz);
            }*/
            UIRectClip(clipRect);
            [image drawInRect:clipRect];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            dispatch_async(dispatch_get_current_queue(), ^{
                self.capturedImaged = newImage;
                [capturedImageView setImage:self.capturedImaged];
                
                NSData *captured = UIImageJPEGRepresentation(self.capturedImaged, 1.0f);
                [appDelegate.capturedImage setObject:captured forKey:@"capturedImage"];
                [self pushPhotoFilterer];
            });
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [capturedImageView setImage:self.capturedImaged];
            
            NSData *captured = UIImageJPEGRepresentation(self.capturedImaged, 1.0f);
            [appDelegate.capturedImage setObject:captured forKey:@"capturedImage"];
            [self pushPhotoCropper];
        });

    }
    
}

-(IBAction)btnGallery:(id)sender {
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}

-(IBAction)btnShutter:(id)sender {
    [self takePicture];
}

- (IBAction)btnViewShutter:(id)sender {
    [self takePicture];
}

- (void) takePicture {
    [self flash];
    [self performSelector:@selector(grabImage) withObject:nil afterDelay:delay];
}

- (void) grabImage {
    hud = [MBProgressHUD showHUDAddedTo:picker.cameraOverlayView animated:YES];
    hud.labelText = @"Capturing";
    [self.picker takePicture];
}


- (IBAction)btnViewGallery:(id)sender {
    [self performSelector:@selector(btnGallery:) withObject:sender];
}

- (IBAction)zoomSlider:(UISlider *)sender {
    self.picker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, sender.value, sender.value);
    zoomScale = sender.value;
    
}

- (IBAction)zoomIn:(id)sender {
    if (zoomSliderObject.value < zoomSliderObject.maximumValue) {
        
    }
    [zoomSliderObject setValue: zoomSliderObject.value + ZOOM_INTERVAL];
    [self performSelector:@selector(zoomSlider:) withObject:zoomSliderObject];
}

- (IBAction)zoomOut:(id)sender {
    if (zoomSliderObject.value > zoomSliderObject.minimumValue) {
        [zoomSliderObject setValue: zoomSliderObject.value - ZOOM_INTERVAL];
    [self performSelector:@selector(zoomSlider:) withObject:zoomSliderObject];
    }
}

//source: http://stackoverflow.com/questions/5882829/how-to-turn-the-iphone-camera-flash-on-off
- (void) flash {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            if (isFlashOn && isCameraRearView) {
                //[device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark - Custom slider

- (void)customiseSlider: (UISlider *)slider {
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 1.5);
    [slider setTransform:trans];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [GVColor navigationBarColor].CGColor);
    CGContextFillRect(context, rect);
    UIImage *minImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    UIImage *maxImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage *zoomHandle = [UIImage imageNamed:@"zoom-handle.png"];
    
    [slider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [slider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [slider setThumbImage:zoomHandle forState:UIControlStateNormal];
}

#pragma mark - Camera button methods

- (void)setCameraViewSettings {
    if (isCameraRearView) {
        isCameraRearView = NO;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else {
        isCameraRearView = YES;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}

- (void)setFlashSettings {
    if (isFlashOn) {
        isFlashOn = NO;
    } else {
        isFlashOn = YES;
    }
}

- (void)setGridSettings {
    if (isGridVisible) {
        isGridVisible = NO;
        [gridImageView setImage:nil];
    } else {
        isGridVisible = YES;
        [gridImageView setImage:[UIImage imageNamed:@"camera-grid.png"]];
    }
}

- (void)setDelay {
    delay = 3;
}

@end
