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

typedef void (^CountBlock)(int count, NSError* error);

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
@property NSString *elevation;
@property NSString *activityTagName;
@property NSString *captionHashTag;


+(int)count;
+(void)countObjectsInBackground:(CountBlock)block;
+(int)countByNearestGeoPoint;
+(int)countNearestGeoPointWithGeoPoint:(PFGeoPoint *)geoPoint;
+(void)countObjectsWithSearchHashTags:(NSArray *)hashTags :(CountBlock)block;

+(void)getLatestPhoto:(ResultBlock)block;
+(void)getFeedsInBackground: (ResultBlock)block;
+(void)getFeedsInBackgroundFrom: (int)start to:(int)max :(ResultBlock)block;
+(void)getFeedsNearGeoPointInBackgroundFrom: (int)start to:(int)max :(ResultBlock)block;
+(void)getFeedsNearGeoPoint:(PFGeoPoint *)geoPoint InBackgroundFrom: (int)start to:(int)max :(ResultBlock)block;
+(void)getFeedsWithSearchString:(NSString *)sstring withParams:(NSArray *)params from: (int)start to:(int)max :(ResultBlock)block;
+(void)getFeedsWithHashTags:(NSArray *)hashTags from:(int)start to:(int)max :(ResultBlock)block;

@end
