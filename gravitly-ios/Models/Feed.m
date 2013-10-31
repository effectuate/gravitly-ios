//
//  Feed.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/11/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "Feed.h"
#import <CoreLocation/CoreLocation.h>

#define GEOLOC_RANGE_KM 3
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
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    return [query countObjects];
}

+(int)countByNearestGeoPoint {
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    
    PFGeoPoint *geoPoint = [[PFGeoPoint alloc] init];
    [geoPoint setLatitude:self.getCurrentLocation.coordinate.latitude];
    [geoPoint setLongitude:self.getCurrentLocation.coordinate.longitude];
    
    [query whereKey:@"geoPoint" nearGeoPoint:geoPoint withinKilometers:GEOLOC_RANGE_KM];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    return [query countObjects];
}

+(void)getLatestPhoto: (ResultBlock)block {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"location"];
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
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"location"];
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
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"location"];
    [query setSkip:start];
    [query setLimit:max];
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
    [query whereKey:@"user" equalTo:user];
    
    PFGeoPoint *geoPoint = [[PFGeoPoint alloc] init];
    [geoPoint setLatitude:self.getCurrentLocation.coordinate.latitude];
    [geoPoint setLongitude:self.getCurrentLocation.coordinate.longitude];
    
    [query whereKey:@"geoPoint" nearGeoPoint:geoPoint withinKilometers:GEOLOC_RANGE_KM];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"location"];
    [query setSkip:start];
    [query setLimit:max];
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

+ (Feed *)convert: (PFObject *)object {
    PFUser *user = [PFUser currentUser];
    Feed *feed = [[Feed alloc] init];
    
    [feed setObjectId:[object objectId]];
    [feed setUser:[user objectForKey:@"username"]];
    
    NSNumber *lat = [object objectForKey:@"latitude"];
    NSNumber *lon = [object objectForKey:@"longitude"];
    [feed setLatitude: lat.floatValue];
    [feed setLongitude: lon.floatValue];
    [feed setLatitudeRef: [object objectForKey:@"latitudeRef"]];
    [feed setLongitudeRef: [object objectForKey:@"longitudeRef"]];
    
    [feed setImageFileName:[object objectForKey:@"filename"]];
    [feed setCaption:[object objectForKey:@"caption"]];
    [feed setHashTags:[object objectForKey:@"hashTags"]];
    [feed setDateUploaded:[object createdAt]];
    [feed setLocationName: [[object objectForKey:@"location"] objectForKey:@"name"]];
    
    return feed;
}


@end
