//
//  AppDelegate.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/16/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSCache *capturedImage;
@property (strong, nonatomic) NSCache *feedImages;
@property (strong, nonatomic) NSCache *libraryImagesCache;
@property (strong, nonatomic) NSCache *filterPlaceholders;

@end
