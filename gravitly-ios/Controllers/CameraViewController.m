//
//  CameraViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "CameraViewController.h"
#import "CropPhotoViewController.h"
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
        
        //picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = NO;
        [[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil];
        self.overlayView.frame = picker.cameraOverlayView.frame;
        picker.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
        self.picker = picker;
        
        [self presentViewController:picker animated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Image Picker delegates

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"taking picture --->");
    NSData *captured = UIImagePNGRepresentation(self.capturedImaged);
    NSPurgeableData *purge = [NSPurgeableData dataWithData:captured];
    
    [appDelegate.capturedImage setObject:purge forKey:@"capturedImage"];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)viewDidDisappear:(BOOL)animated {
    [appDelegate.capturedImage removeObjectForKey:@"capturedImage"];
}

-(IBAction)btnGallery:(id)sender {
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}

-(IBAction)btnShutter:(id)sender {
    [self.picker takePicture];
    
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
    
    self.capturedImaged = newImage;
}

- (IBAction)btnViewShutter:(id)sender {
    [self performSelector:@selector(btnShutter:) withObject:sender];
}

- (IBAction)btnViewGallery:(id)sender {
    [self performSelector:@selector(btnGallery:) withObject:sender];
}

@end