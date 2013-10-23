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

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize {
    
    int start = (page * pageSize) - pageSize;
    int total = [Feed count];
    
    [Feed getFeedsInBackgroundFrom:start to:pageSize :^(NSArray *feeds, NSError *error) {
        [self receivedResults:feeds total:total];
        
    }];
    
    
}

@end
