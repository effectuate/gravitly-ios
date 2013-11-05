//
//  ScoutViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/9/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVBaseViewController.h"

@interface ScoutViewController : GVBaseViewController<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UICollectionView *scoutCollectionView;

@property (strong, nonatomic) IBOutlet UIView *listContainerView;
@property (strong, nonatomic) IBOutlet UIView *collectionContainerView;

@end
