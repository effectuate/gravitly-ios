//
//  Feed.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/11/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "Feed.h"

@implementation Feed

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
        block(objects, error);
    }];
}



@end
