//
//  GVNearestPhotoFeedPaginator.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/21/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVNearestPhotoFeedPaginator.h"
#import "Feed.h"

@implementation GVNearestPhotoFeedPaginator

@synthesize selectedLatitude;
@synthesize selectedLongitude;

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    
    PFGeoPoint *geoPoint = [[PFGeoPoint alloc] init];
    [geoPoint setLatitude:selectedLatitude];
    [geoPoint setLongitude:selectedLongitude];
    
    int start = (page * pageSize) - pageSize;
    int total = [Feed countNearestGeoPointWithGeoPoint:geoPoint];
    
    CountBlock objects = ^(int count, NSError *error) {
        [Feed getFeedsNearGeoPoint:geoPoint InBackgroundFrom:start to:pageSize :^(NSArray *feeds, NSError *error) {
            [self receivedResults:feeds total:total];
        }];
    };
    [Feed countObjectsInBackground:objects];

}

@end
