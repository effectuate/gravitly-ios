//
//  PhotoDetailsViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 8/29/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "PhotoDetailsViewController.h"

@interface PhotoDetailsViewController ()

@end

@implementation PhotoDetailsViewController

@synthesize imageSmall, imageView;

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
    [imageView setImage:imageSmall];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnDone:(id)sender {
    NSLog(@"------> corruption");
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[self performSegueWithIdentifier:@"LoginSuccessSegue" sender:self];
}
@end
