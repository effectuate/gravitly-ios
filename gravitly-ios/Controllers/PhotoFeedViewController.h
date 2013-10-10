//
//  PhotoFeedViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 10/9/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoFeedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *photoTableView;

@property NSArray *photos;

@end
