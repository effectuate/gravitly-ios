//
//  ScoutViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/9/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVBaseViewController.h"

@interface ScoutViewController : GVBaseViewController<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

@end
