//
//  CameraViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "CameraViewController.h"
#import "CropPhotoViewController.h"
#import "FilterViewController.h"
#import "AppDelegate.h"


@interface CameraViewController ()

@end

@implementation CameraViewController {
    AppDelegate *appDelegate;
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
}

- (void)viewWillAppear:(BOOL)animated {
    if (![[appDelegate.capturedImage objectForKey:@"capturedImage"] length]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = NO;
        [[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil];
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
            CGSize newSize = CGSizeMake(cropperView.frame.size.width, cropperView.frame.size.width);
            
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
            CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                         (ratio * image.size.width) + delta,
                                         (ratio * image.size.height) + delta);
            
            
            //start a new context, with scale factor 0.0 so retina displays get
            //high quality image
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
            } else {
                UIGraphicsBeginImageContext(sz);
            }
            UIRectClip(clipRect);
            [image drawInRect:clipRect];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            dispatch_async(dispatch_get_current_queue(), ^{
                self.capturedImaged = newImage;
                [capturedImageView setImage:self.capturedImaged];
                
                NSData *captured = UIImagePNGRepresentation(self.capturedImaged);
                [appDelegate.capturedImage setObject:captured forKey:@"capturedImage"];
                [self dismissViewControllerAnimated:YES completion:NULL];
            });
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [capturedImageView setImage:self.capturedImaged];
            
            NSData *captured = UIImagePNGRepresentation(self.capturedImaged);
            [appDelegate.capturedImage setObject:captured forKey:@"capturedImage"];
            [self dismissViewControllerAnimated:YES completion:NULL];
        });

    }
    
}

-(IBAction)btnGallery:(id)sender {
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}

-(IBAction)btnShutter:(id)sender {
    [self.picker takePicture];
}

- (IBAction)btnViewShutter:(id)sender {
    [self performSelector:@selector(btnShutter:) withObject:sender];
}

- (IBAction)btnViewGallery:(id)sender {
    [self performSelector:@selector(btnGallery:) withObject:sender];
}

@end
