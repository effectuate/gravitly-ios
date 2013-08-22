//
//  MainMenuViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@property (nonatomic) NSMutableArray *capturedImages;

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
    self.capturedImages = [[NSMutableArray alloc] init];
    
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
    picker.allowsEditing = YES;
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"taking picture ---> done");
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.capturedImages addObject:image];
    [self finishAndUpdate];
}


-(void) finishAndUpdate {
    NSLog(@"todo.. go to filter page now..");
}

@end
