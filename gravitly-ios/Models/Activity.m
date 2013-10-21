//
//  Activity.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/8/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define CLASS_NAME_ACTIVITY @"Category"

#import "Activity.h"


@implementation Activity

@synthesize objectId;
@synthesize name;
@synthesize tagName;

+ (void)findAll: (ResultBlock)block {
    [iOSCoreParseHelper findAll:CLASS_NAME_ACTIVITY :^(NSArray *objects, NSError *error) {
        NSMutableArray *activities = [NSMutableArray array];
        for (PFObject *obj in objects) {
            [activities addObject:[self convert:obj]];
        }
        block(activities, error);
    }];
}

+ (void)findAllInBackground: (ResultBlock )block {
    [iOSCoreParseHelper findAllInBackground:CLASS_NAME_ACTIVITY :^(NSArray *objects, NSError *error) {
        NSMutableArray *activities = [NSMutableArray array];
        for (PFObject *obj in objects) {
            NSString *name = [obj objectForKey:@"name"];
            if (![name isEqualToString:@"All/Custom"] && ![name isEqualToString:@"Flight"]) {
                [activities addObject:[self convert:obj]];
            }
        }
        block(activities, error);
    }];
}

+ (Activity *)convert: (PFObject *)object {
    Activity *act = [[Activity alloc] init];
    
    [act setObjectId:[object objectId]];
    [act setName:[object objectForKey:@"name"]];
    [act setTagName:[object objectForKey:@"tagName"]];
    
    return act;
}


@end
