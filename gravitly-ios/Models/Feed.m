//
//  Feed.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/11/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "Feed.h"

@implementation Feed

@synthesize objectId;
@synthesize user;
@synthesize imageFileName;
@synthesize caption;
@synthesize latitude;
@synthesize longitude;
@synthesize dateUploaded;

+(void)getLatestPhoto: (ResultBlock)block {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:user];
    [query orderByDescending:@"createdAt"];
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

+(void)getFeeds: (ResultBlock)block {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:user];
    [query orderByDescending:@"createdAt"];
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
    [feed setImageFileName:[object objectForKey:@"filename"]];
    [feed setCaption:[object objectForKey:@"caption"]];
    [feed setHashTags:[object objectForKey:@"hashTags"]];
    [feed setDateUploaded:[object createdAt]];
    
    return feed;
}


@end
