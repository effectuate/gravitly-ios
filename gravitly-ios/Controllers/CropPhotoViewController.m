//
//  CropPhotoViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/23/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "CropPhotoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BFCropInterface.h"
#import "FilterViewController.h"
#import "UIImage+Resize.h"
#include <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"

@interface CropPhotoViewController ()

@property (strong, nonatomic) UIImagePickerController* picker;

@end

@implementation CropPhotoViewController {
    UIImage *capturedImage;

    ALAssetsLibrary *library;
    NSArray *imageArray;
    NSMutableArray *mutableArray;
    AppDelegate *appDelegate;
}

@synthesize cropPhotoImageView;
@synthesize cropPhotoGridImageView;
@synthesize imageHolder;
@synthesize meta;
@synthesize cropPhotoScrollView;
@synthesize photosCollectionView;
@synthesize navBar;
//@synthesize navBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIImagePickerController *)picker {
    if (!_picker) {
        _picker = [[UIImagePickerController alloc] init];
    }
    return _picker;
}

- (NSArray *)photosTypes {
    return @[@"Camera Roll", @"Group Album", @"Group Event", @"Group Faces", @"Group Photo Stream"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Scale & Crop"];
    [self setBackButton:navBar];
    [self setProceedButton];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self setNavigationBar:navBar title:navBar.topItem.title];

    
    
    [cropPhotoScrollView setDelegate:self];
    
    if (IS_IPHONE_5) {
         NSLog(@"iphone 5");
    } else {
        [cropPhotoScrollView setFrame:CGRectSetY(cropPhotoScrollView.frame, 53)];
        [cropPhotoScrollView setFrame:CGRectSetHeight(cropPhotoScrollView.frame, 300)];
        [cropPhotoImageView setFrame:CGRectSetHeight(cropPhotoImageView.frame, 300)];
        [cropPhotoGridImageView setFrame:CGRectSetHeight(cropPhotoGridImageView.frame, 300)];
        [photosCollectionView setFrame:CGRectSetY(photosCollectionView.frame, 365)];
        [photosCollectionView setFrame:CGRectSetHeight(photosCollectionView.frame, 165)];
        NSLog(@"iphone 4");
    }
    
    cropPhotoScrollView.minimumZoomScale = cropPhotoScrollView.frame.size.width / cropPhotoImageView.frame.size.width;
    cropPhotoScrollView.maximumZoomScale = 2.0;
    [cropPhotoScrollView setBounces:NO];
    [cropPhotoScrollView setZoomScale:cropPhotoScrollView.minimumZoomScale];
    capturedImage = [[UIImage alloc] init];
    mutableArray =[[NSMutableArray alloc] init];
    
    //[self setNavigationBar:self.navigationController.navigationBar title:self.navigationController.navigationBar.topItem.title];
    //[self setBackButton:self.navigationController.navigationBar];
    
    //initial setup
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self getAllImages:ALAssetsGroupSavedPhotos];
    
    NSLog(@"welcome to crop page; your meta data is: %@", meta);
    
    if (appDelegate.filterPlaceholders != nil) {
        [appDelegate createFilterPlaceholders];
    }
    
}

#pragma mark - Get all images

- (void)getAllImages: (ALAssetsGroupType) type {
    imageArray = [[NSArray alloc] init];
    
    //TODO:weekend
    
    /*dispatch_queue_t queue = dispatch_queue_create("ly.gravit.LibraryImages", NULL);
    dispatch_async(queue, ^{*/
        library = [[ALAssetsLibrary alloc] init];
        /*[library enumerateGroupsWithTypes:type usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    ALAssetRepresentation *rep = [result defaultRepresentation];
                    CGImageRef iref = [rep fullResolutionImage];
                    if (iref) {
                        //NSData *data = [appDelegate.libraryImagesCache objectForKey:rep.url.description];
                        //UIImage *image = [UIImage imageWithData:data];
                        //dispatch_async(dispatch_get_main_queue(), ^{
                            [mutableArray addObject:rep.url.absoluteString];
                            
                        //    [photosCollectionView reloadData];
                        //});
                    }
                }];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"error enumerating AssetLibrary groups %@\n", error);
        }];*/
        [library enumerateGroupsWithTypes:type usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [self loadPhotosInGroup:group];
            *stop = YES;
        } failureBlock:^(NSError *error) {
            NSLog(@"Error");
        }];
    //});
}

- (void)loadPhotosInGroup:(ALAssetsGroup *)assetsGroup
{
    NSLog(@">>>> dami ng assets %i", assetsGroup.numberOfAssets);
    __block NSMutableArray *photos = [[NSMutableArray alloc] init]; //[NSMutableArray arrayWithCapacity:assetsGroup.numberOfAssets];
    [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (!result)
            return;
        [photos addObject:result];
        [self reloadCollectionView:photos];
    }];
}

-(void)reloadCollectionView:(NSArray *)photos
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [mutableArray removeAllObjects];
        [mutableArray addObjectsFromArray:photos];
        [photosCollectionView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
    cropPhotoImageView.contentMode = UIViewContentModeScaleAspectFit;
    cropPhotoImageView.userInteractionEnabled = YES;
    
    [cropPhotoImageView setImage:imageHolder];
    
    /*UIView *pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 50)];
    
    [self.picker setDelegate:self];
    [self.picker setNavigationBarHidden:YES];
    [self.picker.view setFrame:CGRectMake(0, 50, self.view.frame.size.width, 50)];
    [pickerView addSubview:self.picker.view];
    [self.view addSubview:pickerView];*/
    
    // allocate crop interface with frame and image being cropped
    /*CGRect cropperSize = CGRectMake(0.0f, 0.0f, cropPhotoImageView.frame.size.width, cropPhotoImageView.frame.size.height);
    
    self.cropper = [[BFCropInterface alloc]initWithFrame:cropperSize andImage:imageHolder];
    
    self.cropper.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.60];
    self.cropper.borderColor = [UIColor whiteColor];
    [cropPhotoImageView addSubview:self.cropper];*/
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"you clicked");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Cropping functions

- (IBAction)crop:(id)sender {
    // crop image
    //UIImage *croppedImage = [self.cropper getCroppedImage];
    
    // remove crop interface from superview
    [self.cropper removeFromSuperview];
    self.cropper = nil;
    
    //CGRect clippedRect = CGRectMake(0, 0, 320, 300);
    capturedImage = [self imageByCropping:cropPhotoScrollView toRect:cropPhotoScrollView.frame];
    
    //[self fixImageZoomScale];
    
    // display new cropped image
    //cropPhotoImageView.image = capturedImage;
}


#pragma mark - Image manipulations

- (UIImage *)imageByCropping:(UIScrollView *)imageToCrop toRect:(CGRect)rect
{
    float pageWidth = rect.size.width * 1;
    float pageHeight = rect.size.height * 1;
    CGSize pageSize = CGSizeMake(pageWidth, pageHeight);
    
    UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0.0);
    {
        CGContextRef resizedContext = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(resizedContext, -imageToCrop.contentOffset.x, -imageToCrop.contentOffset.y);
        
        [imageToCrop.layer renderInContext:resizedContext];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image;
    }
    UIGraphicsEndImageContext();
}

- (IBAction)undo:(id)sender {
    cropPhotoImageView.image = imageHolder;
    if (!self.cropper) {
        self.cropper = [[BFCropInterface alloc]initWithFrame:cropPhotoImageView.bounds andImage:imageHolder];
        [cropPhotoImageView addSubview:self.cropper];
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Back and Proceed button methods

/*- (void)setBackButton
{
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}*/

- (void)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setProceedButton {
    UIButton *proceedButton = [self createButtonWithImageNamed:@"check-big.png"];
    [proceedButton addTarget:self action:@selector(proceedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [proceedButton setFrame:CGRectMake(-1, 0, 50, 44)];
    [proceedButton setBackgroundColor:[GVColor buttonBlueColor]];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.borderColor = [GVColor backgroundDarkColor].CGColor;
    rightBorder.borderWidth = 1.0f;
    rightBorder.frame = CGRectMake(0, 0, 1, CGRectGetHeight(proceedButton.frame));
    [proceedButton.layer addSublayer:rightBorder];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:proceedButton];
    [barButton setBackgroundVerticalPositionAdjustment:-20.0f forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0f) {
        negativeSpacer.width = -16;
    } else {
        negativeSpacer.width = -6; //ios 6 below
    }
    
    [navBar.topItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButton, nil] animated:NO];
    //[self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButton, nil] animated:NO];
}

- (void)proceedButtonTapped:(id)sender
{
    [self performSelector:@selector(crop:) withObject:self];
    [self pushPhotoFilterer];
}

- (void)pushPhotoFilterer {

    FilterViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];
    [fvc setImageHolder:capturedImage];
    [fvc setZoomScale:1.0];
    [fvc setContentOffset:cropPhotoScrollView.contentOffset];
    [fvc setMeta:meta];
    
    NSLog(@"%@ %@ meta", meta.coordinate, meta.altitude);
    //NSLog(@"%f %f offset", cropPhotoScrollView.contentOffset.x, cropPhotoScrollView.contentOffset.y);
    
    //[fvc setMeta:meta];
    cropPhotoImageView.image = capturedImage;
    
    [self.navigationController pushViewController:fvc animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return cropPhotoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"%f %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
    NSLog(@"%f %f %f %f", scrollView.contentInset.top, scrollView.contentInset.bottom, scrollView.contentInset.left, scrollView.contentInset.right);
}

#pragma mark - Collection View delegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return mutableArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:121];
    
    //image
    //ALAssetRepresentation *rep = (ALAssetRepresentation *)[mutableArray objectAtIndex:indexPath.row];
    //CGImageRef iref = [rep fullScreenImage];
   /* NSLog(@"%@", [mutableArray objectAtIndex:indexPath.row]);
    
    UIImage *image = [UIImage imageWithContentsOfFile:[mutableArray objectAtIndex:indexPath.row]];
    [imageView setImage:image];*/
    
    
    /*NSString *mediaurl = [mutableArray objectAtIndex:indexPath.row];
    
    //
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            UIImage *image = [UIImage imageWithCGImage:iref];
            [imageView setImage:image];
        }
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
    };
    
    if(mediaurl && [mediaurl length] && ![[mediaurl pathExtension] isEqualToString:@"JPG"])
    {
        NSURL *asseturl = [NSURL URLWithString:mediaurl];
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:asseturl
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }*/
    
    ALAsset *asset = [mutableArray objectAtIndex:indexPath.row];
    CGImageRef iref = [asset thumbnail];
    imageView.image = [UIImage imageWithCGImage:iref];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    
    cell = [photosCollectionView cellForItemAtIndexPath:indexPath];
    
    ALAsset *asset = [mutableArray objectAtIndex:indexPath.row];
    CGImageRef iref = [asset.defaultRepresentation fullResolutionImage];
    cropPhotoImageView.image = [UIImage imageWithCGImage:iref];
    
}

@end
