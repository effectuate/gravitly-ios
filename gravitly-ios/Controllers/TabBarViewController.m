//
//  TabBarViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "TabBarViewController.h"
#import "GVColor.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

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
    [self setSelectedIndex:2];

    for (int i = 0;i < self.tabBar.items.count;i++) {
        UITabBarItem *item = (UITabBarItem *)self.tabBar.items[i];
        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        //item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item = [item initWithTitle:@"" image:[item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:item.image];
    }
    [[UITabBar appearance] setSelectedImageTintColor:[GVColor redColor]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

@end
