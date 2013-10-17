//
//  CropPhotoViewController.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/23/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVBaseViewController.h"
#import "BFCropInterface.h"
#import "Metadata.h"

@interface CropPhotoViewController : GVBaseViewController <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *cropPhotoImageView;
@property (strong, nonatomic) UIImage *imageHolder;
@property (nonatomic, strong) BFCropInterface *cropper;
@property (strong, nonatomic) Metadata *meta;
@property (strong, nonatomic) IBOutlet UIScrollView *cropPhotoScrollView;
@property (strong, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (strong, nonatomic) IBOutlet UITableView *photosTypeTableView;
@property (strong, nonatomic) IBOutlet UIView *collectionContainerView;

- (IBAction)undo:(id)sender;
- (IBAction)btnAlbums:(id)sender;


@end
