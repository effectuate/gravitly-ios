//
//  GVPhotoFeedPaginator.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/23/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "NMPaginator.h"

@interface GVPhotoFeedPaginator : NMPaginator

@property (strong, nonatomic) NSString *parentVC;
@property (strong, nonatomic) NSString *searchString;
@property (strong, nonatomic) NSArray *hashTags;

@end
