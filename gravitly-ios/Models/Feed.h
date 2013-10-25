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
@property NSString *latitudeRef;
@property NSString *longitudeRef;
@property NSDate *dateUploaded;
@property NSArray *hashTags;
@property NSString *locationName;

+(int)count;

+(void)getLatestPhoto:(ResultBlock)block;
+(void)getFeedsInBackground: (ResultBlock)block;
+(void)getFeedsInBackgroundFrom: (int)start to:(int)max :(ResultBlock)block;

@end
