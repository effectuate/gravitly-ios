//
//  GVSearchHashTagsPaginator.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/27/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVSearchHashTagsPaginator.h"
#import "Feed.h"

@implementation GVSearchHashTagsPaginator

@synthesize hashTags;

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize {
    
    int start = (page * pageSize) - pageSize;
    
    CountBlock countBlock = ^(int count, NSError *error) {
        [Feed getFeedsWithHashTags:hashTags from:start to:pageSize :^(NSArray *feeds, NSError *error) {
            NSLog(@">>>>>>>>> %i >>>>> %i", pageSize, feeds.count);
            [self receivedResults:feeds total:count];
        }];
    };
    [Feed countObjectsWithSearchHashTags:hashTags :countBlock];

}

@end
