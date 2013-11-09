//
//  GVImageView.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/9/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#define WAITING_TIME 30.0 //Waiting before timeout

#import <UIKit/UIKit.h>
#import "GetImageOperation.h"
#import "Feed.h"

@interface GVImageView : UIImageView

@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSString *imageFilename;
@property (strong) GetImageOperation *operation;
@property (strong, nonatomic) NSCache *cachedImages;

//Designated inializer
- (id)initWithFrame:(CGRect)frame urlString:(NSString *)urlString tag:(NSUInteger)tag;
- (void)getImageFromNetwork:(NSOperationQueue *)queue;

@end
