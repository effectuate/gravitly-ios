//
//  SearchResultsViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/27/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVBaseViewController.h"
#import "GVSearchHashTagsPaginator.h"
#import "GVNearestPhotoFeedPaginator.h"
#import "Feed.h"

@interface SearchResultsViewController : GVBaseViewController <NMPaginatorDelegate>

@property (nonatomic) GVSearch searchPurpose;
@property (nonatomic, strong) Feed *selectedFeed;

@end
