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
#import <AFNetworkActivityIndicatorManager.h>
#import "UIImage+Resize.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <GPUImage.h>

@implementation AppDelegate

@synthesize capturedImage;
@synthesize feedImages;
@synthesize libraryImagesCache;
@synthesize filterPlaceholders;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //parse credentials
    
    [Parse setApplicationId:@"bSm5oGK8VnmtD8hBtkhDyPV9qhE2gU87uCGQH4vd"
                  clientKey:@"dG2NPyKXzC2fZK0VS0MTY4fWwwbGWXwGzU8Venpn"];
    
    [TestFlight takeOff:@"3e8b52da-96e3-4b69-adb6-ad401fc6fd43  "];
    
    [PFFacebookUtils initializeFacebook];
    
    [self customiseNavigationBar];
    [self customiseTabBar];

    // Override point for customization after application launch.
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //dummy twitter account
    [PFTwitterUtils initializeWithConsumerKey:@"rp7eWytARqeh53NkrZSLw" consumerSecret:@"PglmgmQknDxBH75ClZF7Fdl0RgWnzM5LLxZNtGi4"];
    
    [FBSession setActiveSession:nil];
    
    [application setStatusBarHidden:YES];
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    
    //cache the image
    [self getAllImages:ALAssetsGroupAll];
    libraryImagesCache = [[NSCache alloc] init];
    filterPlaceholders = [[NSCache alloc] init];
    [self createFilterPlaceholders];
    
    return YES;
}

- (void)createFilterPlaceholders {
    
    NSArray *filters = @[@"1977", @"Brannan", @"Gotham", @"Hefe", @"Lord Kelvin", @"Nashville", @"X-PRO II", @"yellow-red", @"aqua", @"crossprocess"];
    UIImage *image = [UIImage imageNamed:@"filter-placeholder@2x.png"];

    dispatch_queue_t queue = dispatch_queue_create("ly.gravit.FiteringPlaceholders", NULL);
    dispatch_async(queue, ^{
        for (NSString *fltr in filters) {
            GPUImageFilter *selectedFilter = [[GPUImageToneCurveFilter alloc] initWithACV:fltr];
            [filterPlaceholders setObject:UIImagePNGRepresentation([selectedFilter imageByFilteringImage:image]) forKey:fltr];
        }
    });
    
}


- (void)getAllImages: (ALAssetsGroupType) type {
    //TODO:weekend
    
    dispatch_queue_t queue = dispatch_queue_create("ly.gravit.LibraryImages", NULL);
    dispatch_async(queue, ^{
        NSLog(@">>> CACHING IMAGES FROM LIBRARY");
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:type usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    ALAssetRepresentation *rep = [result defaultRepresentation];
                    CGImageRef iref = [rep fullScreenImage];
                    
                    if (iref) {
                        UIImage *largeimage = [UIImage imageWithCGImage:iref];
                        //UIImage *smallImage = [largeimage resizeImageToSize:CGSizeMake(largeimage.size.width * .05f, largeimage.size.height * .05f)];
                        UIImage *smallImage = [UIImage imageWithCGImage:[result thumbnail]];
                        NSData *data = UIImagePNGRepresentation(smallImage);
                        [libraryImagesCache setObject:data forKey:rep.url.description];
                    }
                    
                }];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"error enumerating AssetLibrary groups %@\n", error);
        }];
    });
}

- (void)sampleCaching {

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
