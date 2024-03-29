//
//  Feed.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/11/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "Feed.h"
#import <CoreLocation/CoreLocation.h>
#import "GVPhotoFeedPaginator.h"

#define GEOLOC_RANGE_KM 3
#define GEOLOC_RANGE_KM_MIN 1
#define GEOLOC_RANGE_MI 3

@implementation Feed

@synthesize objectId;
@synthesize user;
@synthesize imageFileName;
@synthesize caption;
@synthesize latitude;
@synthesize longitude;
@synthesize dateUploaded;
@synthesize locationName;
@synthesize latitudeRef;
@synthesize longitudeRef;
@synthesize elevation;
@synthesize activityTagName;
@synthesize captionHashTag;
@synthesize flag;

+(CLLocation *)getCurrentLocation {
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    [manager setDesiredAccuracy:kCLLocationAccuracyBest];
    [manager startUpdatingLocation];
    
    NSLog(@"%f --- %f", manager.location.coordinate.latitude, manager.location.coordinate.longitude);
    
    return manager.location;
}

+(int)count {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    return [query countObjects];
}

+(void)countObjectsInBackground:(CountBlock)block
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:user];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    //[query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        block(number, error);
    }];
}

+(void)countByNearestGeoPoint:(CountBlock)block
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    
    PFGeoPoint *geoPoint = [[PFGeoPoint alloc] init];
    [geoPoint setLatitude:self.getCurrentLocation.coordinate.latitude];
    [geoPoint setLongitude:self.getCurrentLocation.coordinate.longitude];
    
    [query whereKey:@"geoPoint" nearGeoPoint:geoPoint withinKilometers:GEOLOC_RANGE_KM];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        block(number, error);
    }];
}

/*+(int)countByNearestGeoPoint:(CountBlock)block
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    
    PFGeoPoint *geoPoint = [[PFGeoPoint alloc] init];
    [geoPoint setLatitude:self.getCurrentLocation.coordinate.latitude];
    [geoPoint setLongitude:self.getCurrentLocation.coordinate.longitude];
    
    [query whereKey:@"geoPoint" nearGeoPoint:geoPoint withinKilometers:GEOLOC_RANGE_KM];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    return [query countObjects];
}*/

+(int)countNearestGeoPointWithGeoPoint:(PFGeoPoint *)geoPoint
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"geoPoint" nearGeoPoint:geoPoint withinKilometers:GEOLOC_RANGE_KM];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    return [query countObjects];
}

+(void)countObjectsWithSearchHashTags:(NSArray *)hashTags :(CountBlock)block
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"hashTags" containsAllObjectsInArray:hashTags];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        block(objects.count, error);
    }];
}

+(void)getLatestPhoto: (ResultBlock)block {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"location"];
    [query includeKey:@"category"];
    [query includeKey:@"user"];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            NSMutableArray *feeds = [NSMutableArray array];
            for (PFObject *obj in objects) {
                [feeds addObject:[self convert:obj]];
            }
            block(feeds, error);
        }
    }];
}

+(void)getFeedsInBackground: (ResultBlock)block {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"location"];
    [query includeKey:@"category"];
    [query includeKey:@"user"];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            NSMutableArray *feeds = [NSMutableArray array];
            for (PFObject *obj in objects) {
                [feeds addObject:[self convert:obj]];
            }
            block(feeds, error);
        }
    }];
}

+(void)getFeedsInBackgroundFrom: (int)start to:(int)max :(ResultBlock)block {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    //[query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"location"];
    [query includeKey:@"category"];
    [query includeKey:@"user"];
    [query setSkip:start];
    [query setLimit:max];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            NSMutableArray *feeds = [NSMutableArray array];
            for (PFObject *obj in objects) {
                [feeds addObject:[self convert:obj]];
            }
            block(feeds, error);
        }
    }];
}

+(void)getFeedsNearGeoPointInBackgroundFrom: (int)start to:(int)max :(ResultBlock)block {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    //[query whereKey:@"user" notEqualTo:user];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    
    PFGeoPoint *geoPoint = [[PFGeoPoint alloc] init];
    [geoPoint setLatitude:self.getCurrentLocation.coordinate.latitude];
    [geoPoint setLongitude:self.getCurrentLocation.coordinate.longitude];
    
    [query whereKey:@"geoPoint" nearGeoPoint:geoPoint withinKilometers:GEOLOC_RANGE_KM];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"location"];
    [query includeKey:@"category"];
    [query includeKey:@"user"];
    [query setSkip:start];
    [query setLimit:max];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            NSMutableArray *feeds = [NSMutableArray array];
            for (PFObject *obj in objects) {
                [feeds addObject:[self convert:obj]];
            }
            block(feeds, error);
        }
    }];
}

+(void)getFeedsNearGeoPoint:(PFGeoPoint *)geoPoint InBackgroundFrom: (int)start to:(int)max :(ResultBlock)block
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    //[query whereKey:@"user" notEqualTo:user];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    
    [query whereKey:@"geoPoint" nearGeoPoint:geoPoint withinKilometers:GEOLOC_RANGE_KM_MIN];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"location"];
    [query includeKey:@"category"];
    [query includeKey:@"user"];
    [query setSkip:start];
    [query setLimit:max];
    
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            NSMutableArray *feeds = [NSMutableArray array];
            for (PFObject *obj in objects) {
                [feeds addObject:[self convert:obj]];
            }
            block(feeds, error);
        }
    }];
}

+(void)getFeedsWithSearchString:(NSString *)sstring withParams:(NSArray *)params from: (int)start to:(int)max :(ResultBlock)block {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    //[query whereKey:@"user" equalTo:user];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    
    PFGeoPoint *geoPoint = [[PFGeoPoint alloc] init];
    [geoPoint setLatitude:self.getCurrentLocation.coordinate.latitude];
    [geoPoint setLongitude:self.getCurrentLocation.coordinate.longitude];
    
    //[query whereKey:@"geoPoint" nearGeoPoint:geoPoint withinKilometers:GEOLOC_RANGE_KM];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"location"];
    [query includeKey:@"category"];
    [query includeKey:@"user"];
    /*if (params.count > 0) {
        NSSet *paramsSet = [NSSet setWithArray:params];
        NSSet *hashTagsSet = [NSSet setWithArray:@[@"Location"]];
        [hashTagsSet intersectsSet:paramsSet];
        
        NSLog(@"%@", hashTagsSet);
        
        if (hashTagsSet.allObjects.count) {
            //[query whereKey:@"hashTags" containedIn:params];
            [query whereKey:@"hashTags" containedIn:hashTagsSet.allObjects];
            NSLog(@">>> count %i", [query countObjects]);
        }
        
    }*/
    
    if (sstring) {
        [query whereKey:@"caption" containsString:sstring];
    }
    
    [query setSkip:start];
    [query setLimit:max];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            NSMutableArray *feeds = [NSMutableArray array];
            for (PFObject *obj in objects) {
                [feeds addObject:[self convert:obj]];
            }
            block(feeds, error);
        }
    }];
}

+(void)getFeedsWithHashTags:(NSArray *)hashTags from:(int)start to:(int)max :(ResultBlock)block
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"hashTags" containsAllObjectsInArray:hashTags];
    [query whereKey:@"isFlagged" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    [query includeKey:@"category"];
    [query includeKey:@"user"];
    [query setSkip:start];
    [query setLimit:max];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            NSMutableArray *feeds = [NSMutableArray array];
            for (PFObject *obj in objects) {
                [feeds addObject:[self convert:obj]];
            }
            block(feeds, error);
        }
    }];
}

-(void)flagFeedInBackground:(SuccessBlock)block
{
    PFObject *photo = [PFObject objectWithoutDataWithClassName:@"Photo" objectId:self.objectId];
    PFUser *reporter = [PFUser currentUser];
    PFObject *flagging = [PFObject objectWithClassName:@"PhotoFlagging"];
    [flagging setObject:photo forKey:@"photo"];
    [flagging setObject:reporter forKey:@"reporter"];
    [flagging saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        block(succeeded, error);
    }];
}

-(void)unflagFeedInBackground:(SuccessBlock)block
{
    PFObject *photo = [PFObject objectWithoutDataWithClassName:@"Photo" objectId:self.objectId];
    PFUser *reporter = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"PhotoFlagging"];
    [query whereKey:@"photo" equalTo:photo];
    [query whereKey:@"reporter" equalTo:reporter];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *obj in objects) {
            [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                block(succeeded, error);
            }];
        }
    }];
}

+ (Feed *)convert: (PFObject *)object {
    PFUser *user = [object objectForKey:@"user"];
    Feed *feed = [[Feed alloc] init];
    
    [feed setObjectId:[object objectId]];
    [feed setUser:user];
    
    NSNumber *lat = [object objectForKey:@"latitude"];
    NSNumber *lon = [object objectForKey:@"longitude"];
    [feed setLatitude: lat.floatValue];
    [feed setLongitude: lon.floatValue];
    
    feed.latitudeRef = [object objectForKey:@"latitudeRef"] == nil ? @"" : [object objectForKey:@"latitudeRef"];
    feed.longitudeRef = [object objectForKey:@"longitudeRef"] == nil ? @"" : [object objectForKey:@"longitudeRef"];
    
    [feed setImageFileName:[object objectForKey:@"filename"]];
    feed.caption = [object objectForKey:@"caption"] == nil ? @"" : [object objectForKey:@"caption"];
    [feed setHashTags:[object objectForKey:@"hashTags"]];
    [feed setDateUploaded:[object createdAt]];
    feed.locationName = [object objectForKey:@"locationName"] == nil ? @"Unnamed Location" : [NSString stringWithFormat:@"%@", [object objectForKey:@"locationName"]];
    NSNumber *altitudeM = [object objectForKey:@"altitude"];
    feed.elevation = [object objectForKey:@"altitude"] == nil ? @"Offline" : [NSString stringWithFormat:@"%.4f m", altitudeM.floatValue];
    feed.activityTagName = [[object objectForKey:@"category"] objectForKey:@"tagName"];
    [self checkFeedIfFlagged:feed.objectId
                   withBlock:^(BOOL succeeded, NSError *error) {
                       if (succeeded) {
                           [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BUTTON_UI_UPDATE
                                                                               object:self
                                                                             userInfo:@{@"objectId": feed.objectId}];
                       }
                       feed.flag = succeeded;
                   }];
    
    //[feed setLocationName: [[object objectForKey:@"location"] objectForKey:@"name"]];
    
    NSString *tagString = @"";
    for (NSString *tag in feed.hashTags) {
        tagString = [NSString stringWithFormat:@"%@#%@ ", tagString, tag];
    }
    
    tagString = [NSString stringWithFormat:@"%@ %@", feed.caption, tagString];
    [feed setCaptionHashTag:tagString];
    
    return feed;
}

+ (void)checkFeedIfFlagged:(NSString *)objectId withBlock :(SuccessBlock)block
{
    PFQuery *query = [PFQuery queryWithClassName:@"PhotoFlagging"];
    [query whereKey:@"reporter" equalTo:[PFUser currentUser]];
    [query whereKey:@"photo" equalTo:[PFObject objectWithoutDataWithClassName:@"Photo" objectId:objectId]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number > 0) {
            block(YES, error);
        } else {
            block(NO, error);
        }
    }];
}

@end
