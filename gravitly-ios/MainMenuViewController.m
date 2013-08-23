//
//  MainMenuViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "MainMenuViewController.h"
#import "CropPhotoViewController.h"

@interface MainMenuViewController ()

@property (nonatomic) UIImage *capturedImaged;

@property (nonatomic) UIImagePickerController *picker;

@end

@implementation MainMenuViewController

@synthesize overlayView;

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
    [self presentViewController:picker animated:YES completion:nil];
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"taking picture ---> done");
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //[self.capturedImages addObject:image];
    self.capturedImaged = image;
    [self finishAndUpdate];
}


-(void) finishAndUpdate {
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"todo.. go to cropping and filter page now..");
    CropPhotoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CropPhoto"];
    vc.imageHolder = self.capturedImaged;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
