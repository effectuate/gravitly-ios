//
//  MapLightBoxViewController
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/9/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVBaseViewController.h"
#import "Feed.h"
#import "GVPhotoFeedPaginator.h"
#import "GVImageView.h"

@protocol MapLightBoxViewDelegate <NSObject>

@optional

- (void)lightBoxDidClose;

@end

@interface MapLightBoxViewController : GVBaseViewController <UICollectionViewDelegate, UICollectionViewDataSource, NMPaginatorDelegate>

@property (nonatomic, assign) id <MapLightBoxViewDelegate> delegate;
//@property (nonatomic, assign) id <UICollectionViewDataSource> dataSource;

@end
