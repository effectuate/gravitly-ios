//
//  GVBaseViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/3/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVBaseViewController.h"

@interface GVBaseViewController ()

@end

@implementation GVBaseViewController {
    AppDelegate *appDelegate;
}

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
    [self.tabBarController setDelegate:self];
    [self.view setBackgroundColor:[GVColor backgroundDarkBlueColor]];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.capturedImage = [[NSCache alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customiseTable: (UITableView *)tableView {
    [tableView setScrollEnabled:NO];
    [tableView setSeparatorColor:[GVColor separatorColor]];
}

- (SocialMediaAccountsController *)smaView: (NSString *)label{
    SocialMediaAccountsController *social = (SocialMediaAccountsController *)[[[NSBundle mainBundle] loadNibNamed:@"SocialMediaAccountsView" owner:self options:nil] objectAtIndex:0];
    [social.label setText:label];
    return social;
}

#pragma mark - Background methods

- (void)setBackgroundColor:(UIColor *)color {
    [self.view setBackgroundColor:color];
}

#pragma mark - Get cached captured image

-(UIImage *)getCapturedImage {
    NSData *data = [appDelegate.capturedImage objectForKey:@"capturedImage"];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

#pragma mark - Navigation bar button methods

-(UIButton *)createButtonWithImageNamed: (NSString *)image {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 32, 32)];
    return button;
}

- (UIBarButtonItem *)setBackButton:(UINavigationBar *)navBar
{
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [navBar.topItem setLeftBarButtonItem:barButton];
    return barButton;
}

-(void)setNavigationBar:(UINavigationBar *)navBar title:(NSString *)title {
    GVLabel *navTitleLabel = [[GVLabel alloc] initWithFrame:CGRectMake(0,0,200,40)];
    navTitleLabel.backgroundColor = [UIColor clearColor];
    [navTitleLabel setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize];
    [navTitleLabel setTextAlignment:NSTextAlignmentLeft];
    navTitleLabel.text = title;
    navBar.topItem.titleView = navTitleLabel;
}

- (void)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Present tab bar controller

- (void)presentTabBarController: (id)delegate {
    UITabBarController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"StartController"];
    [delegate presentViewController:svc animated:YES completion:nil];
}

@end
