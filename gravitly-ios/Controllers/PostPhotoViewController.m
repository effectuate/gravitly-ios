//
//  PostPhotoViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/10/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "PostPhotoViewController.h"
#import "AddActivityViewController.h"
#import "GVHTTPClient.h"
#import <AFJSONRequestOperation.h>
#import <AFNetworkActivityIndicatorManager.h>

@interface PostPhotoViewController ()

@end

@implementation PostPhotoViewController

@synthesize imageHolder;
@synthesize thumbnailImageView;
@synthesize captionTextView;
@synthesize smaView;
@synthesize activityButton;
@synthesize enhancementsButton;

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
    [self.navigationItem setTitle:@"Post"];
    [self setBackButton];
    [self setRightBarButtons];
    [self.captionTextView setText:@"Add Caption"];
    //[self.captionTextView setDelegate:self];
    SocialMediaAccountsController *sma = [self smaView:@"Share to:"];
    [sma setBackgroundColor:[GVColor backgroundDarkColor]];
    [smaView addSubview:sma];   
	[self.thumbnailImageView setImage: self.imageHolder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)setBackButton
{
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)setRightBarButtons {
    UIButton *lockButton = [self createButtonWithImageNamed:@"lock.png"];
    [lockButton addTarget:self action:@selector(lockTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *proceedButton = [self createButtonWithImageNamed:@"check-big.png"];
    [proceedButton addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *buttons = @[[[UIBarButtonItem alloc] initWithCustomView:proceedButton], [[UIBarButtonItem alloc] initWithCustomView:lockButton]];
    
    self.navigationItem.rightBarButtonItems = buttons;
}

-(IBAction)lockTapped:(id)sender {
    NSLog(@"tinap mo ung lock");
}

-(void)upload {
    
    //NSURL *url = [NSURL URLWithString:@"http://webapi.webnuggets.cloudbees.net/admin/upload"]; //http://192.168.0.52:9000
    NSData *data = UIImageJPEGRepresentation(imageHolder, 1.0);
    
    static NSString *imageKey = @"image";
    static NSString *captionKey = @"caption";
    static NSString *filenameKey = @"filename";
    static NSString *userKey = @"user";
    static NSString *categoryIdKey = @"category";//@"categoryId";
    static NSString *locationIdKey = @"location";//@"locationId";
    
    if (data) {
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"caption", captionKey,
                                @"sample.png", filenameKey,
                                @"LsmI34VlUu", userKey,
                                @"uoabsxZmSB", categoryIdKey,
                                @"u6ffhvdZJH", locationIdKey,
                                nil];
        
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://192.168.0.124:19000/"]];
        //[client clearAuthorizationHeader];
        //[client setAuthorizationHeaderWithUsername:@"kingslayer07" password:@"password"];
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"admin/upload" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:imageKey fileName:@"temp.jpg" mimeType:@"image/jpeg"];
        }];
    
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            NSLog(@"----> %lld of %lld", totalBytesWritten, totalBytesExpectedToWrite);
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self presentTabBarController:self];
            NSLog(@"upload success!");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if([operation.response statusCode] == 403)
            {
                NSLog(@"Upload Failed");
                return;
            }
            NSLog(@"error %@", error);
        }];
        
        [operation start];
    }
    
    //[client clearAuthorizationHeader];
    //[client setAuthorizationHeaderWithUsername:@"kingslayer07" password:@"password"];
    
   // NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:@"http://webapi.webnuggets.cloudbees.net/admin/upload" parameters:params];
    
   
    

}

- (IBAction)addActivity:(id)sender {
    AddActivityViewController *aavc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddActivityViewController"];
    [self.navigationController  pushViewController:aavc animated:YES];
}

- (IBAction)addEnhancement:(id)sender {
    NSLog(@"asdfasdfasdf");
}
@end
