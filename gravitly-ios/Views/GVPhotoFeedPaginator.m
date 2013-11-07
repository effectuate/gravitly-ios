//
//  GVPhotoFeedPaginator.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/23/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVPhotoFeedPaginator.h"
#import "Feed.h"

@implementation GVPhotoFeedPaginator

@synthesize parentVC;

- (NSString *)searchString {
    return (_searchString) ? _searchString : nil;
}

-(NSArray *)hashTags {
    if (!_hashTags){
        _hashTags = nil;
    }
    return _hashTags;
}

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize {
    
    int start = (page * pageSize) - pageSize;
    int total = 0;
    
    if ([parentVC isEqualToString:@"ScoutViewController"]) {
        total = [Feed countByNearestGeoPoint];
        [Feed getFeedsNearGeoPointInBackgroundFrom:start to:pageSize :^(NSArray *feeds, NSError *error) {
            [self receivedResults:feeds total:total];
        }];
    } else if ([parentVC isEqualToString:@"Search"]) {
        
        [Feed getFeedsWithSearchString:[self searchString] withParams:[self hashTags] from:start to:pageSize :^(NSArray *objects, NSError *error) {
            [self receivedResults:objects total:objects.count];
        }];
        
        //todo total
    } else {
        total = [Feed count];
        [Feed getFeedsInBackgroundFrom:start to:pageSize :^(NSArray *feeds, NSError *error) {
            [self receivedResults:feeds total:total];
        }];
    }
    
}

@end
