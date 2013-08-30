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
    NSLog(@"sending request");
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //doing send reqeust to web api..
    /*
    NSURL *url = [NSURL URLWithString:@"http://192.168.0.50:9000/admin/upload"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    
    NSData *requestBody = [@"message=fackkk" dataUsingEncoding:NSUTF8StringEncoding];
    
    //send request
    [req setHTTPBody:requestBody];
    
    //... set everything else
    NSData *res = [NSURLConnection  sendSynchronousRequest:req returningResponse:NULL error:NULL];
    NSLog(@"%@", res);
    */
}
@end
