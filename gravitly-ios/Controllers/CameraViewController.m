//
//  CameraViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define TAG_CAMERA_OVERLAY_NAVBAR 100
#define TAG_CAMERA_OVERLAY_GRID_IMAGE_VIEW 101

#import "CameraViewController.h"
#import "CropPhotoViewController.h"
#import "FilterViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

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
}

@synthesize cropperView;
@synthesize overlayView;
@synthesize capturedImaged;
@synthesize picker;
@synthesize capturedImageView;
@synthesize cameraGridImageView;

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
    
    if (![[appDelegate.capturedImage objectForKey:@"capturedImage"] length]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = NO;
        
        //set which camera to use rear or front
        //source: http://stackoverflow.com/questions/3669214/set-front-facing-camera-in-iphone-sdk
        
        UIView *cameraOverlayView = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil] objectAtIndex:0];
        UINavigationBar *navBar = (UINavigationBar *)[cameraOverlayView viewWithTag:TAG_CAMERA_OVERLAY_NAVBAR];
        gridImageView = (UIImageView *)[cameraOverlayView viewWithTag:TAG_CAMERA_OVERLAY_GRID_IMAGE_VIEW];
        [self setRightBarButtons:navBar];
        
        self.overlayView.frame = picker.cameraOverlayView.frame;
        
        picker.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
        self.picker = picker;
        
        [self presentViewController:picker animated:NO completion:nil];
    } else {
        switch (picker.sourceType) {
            case 2:
                [capturedImageView setImage:self.capturedImaged];
                [self performSelector:@selector(presentPhotoCropper) withObject:nil afterDelay:1.0];
                break;
                
            default:
                [capturedImageView setImage:self.capturedImaged];
                [self performSelector:@selector(presentPhotoFilterer) withObject:nil afterDelay:0.5];
                break;
        }
    }
}

- (void)presentPhotoFilterer {
    FilterViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];
    [fvc setImageHolder:self.capturedImaged];
    [fvc setZoomScale:zoomScale];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:fvc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)presentPhotoCropper {
    CropPhotoViewController *cpvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CropPhotoViewController"];
    [cpvc setImageHolder:self.capturedImaged];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cpvc];
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Nav buttons

- (void)setRightBarButtons: (UINavigationBar *) navbar {
    navbar.topItem.title = @"Camera                    ";
    
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

#pragma mark - Image Picker delegates

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.capturedImaged = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            double ratio;
            double delta;
            CGPoint offset;
            
            //make a new square size, that is the resized imaged width
            
            CGSize newSize = CGSizeMake(/*cropperView.frame.size.width*/612.0f * zoomScale, /*cropperView.frame.size.width*/612.0f * zoomScale);
            
            CGSize sz = CGSizeMake(newSize.width, newSize.width);
            
            UIImage *image = self.capturedImaged;
            
            //figure out if the picture is landscape or portrait, then
            //calculate scale factor and offset
            ratio = (newSize.width) / (image.size.height);
            delta = (ratio * image.size.height - ratio * (image.size.width));
            offset = CGPointMake(0, delta/2);
                
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
                [self dismissViewControllerAnimated:YES completion:NULL];
            });
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [capturedImageView setImage:self.capturedImaged];
            
            NSData *captured = UIImageJPEGRepresentation(self.capturedImaged, 1.0f);
            [appDelegate.capturedImage setObject:captured forKey:@"capturedImage"];
            [self dismissViewControllerAnimated:YES completion:NULL];
        });

    }
    
}

-(IBAction)btnGallery:(id)sender {
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}

-(IBAction)btnShutter:(id)sender {
    //[self.picker takePicture];
    [self takePicture];
}

- (IBAction)btnViewShutter:(id)sender {
    [self takePicture];
    //[self performSelector:@selector(btnShutter:) withObject:sender];
    //[self performSelector:@selector(btnShutter:) withObject:sender afterDelay:3];
    
    //another way of doing delay..
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSLog(@"WTF?");
        [self performSelector:@selector(btnShutter:) withObject:sender];
    });
    */
    
}

- (void) takePicture {
    [self flash];
    
    if (true) {
        NSLog(@"with delay");
        //without delay..
        //[self grabImage];
        [self performSelector:@selector(grabImage) withObject:nil afterDelay:delay];
    } else {
        NSLog(@"withOUT delay");
        //with delay..
        [self performSelector:@selector(grabImage) withObject:nil afterDelay:delay];
    }
}

- (void) grabImage {
    [self.picker takePicture];
}


- (IBAction)btnViewGallery:(id)sender {
    [self performSelector:@selector(btnGallery:) withObject:sender];
}

- (IBAction)zoomSlider:(UISlider *)sender {
    self.picker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, sender.value, sender.value);
    zoomScale = sender.value;
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
