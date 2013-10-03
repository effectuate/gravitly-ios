//
//  AppDelegate.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/16/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "GVCommons.h"
#import <TestFlight.h>
#import <AFNetworking.h>

@implementation AppDelegate

@synthesize capturedImage;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //parse credentials
    
    [Parse setApplicationId:@"bSm5oGK8VnmtD8hBtkhDyPV9qhE2gU87uCGQH4vd"
                  clientKey:@"dG2NPyKXzC2fZK0VS0MTY4fWwwbGWXwGzU8Venpn"];
    
    [TestFlight takeOff:@"72e34665-d67e-4be7-8665-3a8bdef14fa4"];
    
    [self customiseNavigationBar];
    [self customiseTabBar];

    // Override point for customization after application launch.
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //dummy twitter account
    [PFTwitterUtils initializeWithConsumerKey:@"rp7eWytARqeh53NkrZSLw" consumerSecret:@"PglmgmQknDxBH75ClZF7Fdl0RgWnzM5LLxZNtGi4"];
    
    return YES;
}



- (void)customiseNavigationBar {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [GVColor navigationBarColor].CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[GVColor textPaleGrayColor], [UIFont fontWithName:kgvRobotoCondensedRegular size:kgvFontSize], [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], nil] forKeys:[NSArray arrayWithObjects:UITextAttributeTextColor, UITextAttributeFont, UITextAttributeTextShadowOffset,nil]]];
    }
}

- (void)customiseTabBar {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [GVColor navigationBarColor].CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[UITabBar appearance] setBackgroundImage:image];
    [[UITabBar appearance] setSelectionIndicatorImage:image];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

@end
