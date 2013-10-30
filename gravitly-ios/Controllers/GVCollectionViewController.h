//
//  GVCollectionViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/30/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVPhotoFeedPaginator.h"

@interface GVCollectionViewController : UICollectionViewController<NMPaginatorDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *photoFeedCollectionView;
@property NMPaginator *paginator;

@end
