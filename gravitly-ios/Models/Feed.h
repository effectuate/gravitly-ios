//
//  Feed.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/11/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSCoreParseHelper.h"

@interface Feed : NSObject

@property NSString *objectId;
@property NSString *user; // TODO:change to PFuser
@property NSString *imageFileName;
@property NSString *caption;
@property float latitude;
@property float longitude;
@property NSDate *dateUploaded;
@property NSArray *hashTags;
@property NSString *locationName;

+ (void)getLatestPhoto:(ResultBlock)block;
+(void)getFeeds: (ResultBlock)block;

@end
