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

@interface CropPhotoViewController ()

@end

@implementation CropPhotoViewController {
    UIImage *capturedImage;
    ALAssetsLibrary *library;
    NSArray *imageArray;
    NSMutableArray *mutableArray;
}

@synthesize cropPhotoImageView;
@synthesize imageHolder;
@synthesize meta;
@synthesize cropPhotoScrollView;
@synthesize photosCollectionView;
@synthesize photosTypeTableView;
@synthesize collectionContainerView;
@synthesize photoSetLabel;
//@synthesize navBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)photosTypes {
    return @[@"Camera Roll", @"Group Album", @"Group Event", @"Group Faces", @"Group Photo Stream"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackButton];
    [self setProceedButton];
    [self.navigationItem setTitle:@"Scale & Crop"];
    
    [cropPhotoScrollView setDelegate:self];
    cropPhotoScrollView.minimumZoomScale = cropPhotoScrollView.frame.size.width / cropPhotoImageView.frame.size.width;
    cropPhotoScrollView.maximumZoomScale = 2.0;
    [cropPhotoScrollView setBounces:NO];
    [cropPhotoScrollView setZoomScale:cropPhotoScrollView.minimumZoomScale];
    capturedImage = [[UIImage alloc] init];
    mutableArray =[[NSMutableArray alloc] init];
    
    [self setNavigationBar:self.navigationController.navigationBar title:self.navigationController.navigationBar.topItem.title];
    
    //initial setup
    
    [self getAllImages:ALAssetsGroupAll];
    
    [photoSetLabel setLabelStyle:GVRobotoCondensedRegularBlueColor size:kgvFontSize];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    cropPhotoImageView.contentMode = UIViewContentModeScaleAspectFit;
    cropPhotoImageView.userInteractionEnabled = YES;
    
    [cropPhotoImageView setImage:imageHolder];
    
    // allocate crop interface with frame and image being cropped
    /*CGRect cropperSize = CGRectMake(0.0f, 0.0f, cropPhotoImageView.frame.size.width, cropPhotoImageView.frame.size.height);
    
    self.cropper = [[BFCropInterface alloc]initWithFrame:cropperSize andImage:imageHolder];
    
    self.cropper.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.60];
    self.cropper.borderColor = [UIColor whiteColor];
    [cropPhotoImageView addSubview:self.cropper];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get all images

- (void)getAllImages: (ALAssetsGroupType) type {
    imageArray = [[NSArray alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        library = [[ALAssetsLibrary alloc] init];
        
        
        [library enumerateGroupsWithTypes:type usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    
                    
                    ALAssetRepresentation *rep = [result defaultRepresentation];
                    CGImageRef iref = [rep fullResolutionImage];
                    if (iref) {
                        UIImage *largeimage = [UIImage imageWithCGImage:iref];
                        UIImage *smallImage = [largeimage resizeImageToSize:CGSizeMake(largeimage.size.width * .05f, largeimage.size.height * .05f)];
                        [mutableArray addObject:smallImage];
                        NSLog(@">>> %i", mutableArray.count);
                        
                        [photosCollectionView reloadData];
                    }
                    
                }];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"error enumerating AssetLibrary groups %@\n", error);
        }];
    });
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

- (void)setBackButton
{
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setProceedButton {
    
    UIButton *proceedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [proceedButton setImage:[UIImage imageNamed:@"check-big.png"] forState:UIControlStateNormal];
    [proceedButton addTarget:self action:@selector(proceedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [proceedButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:proceedButton]];
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
    
    NSLog(@"%f %f offset", cropPhotoScrollView.contentOffset.x, cropPhotoScrollView.contentOffset.y);
    
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
    
    cell = [photosCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:121];
    [imageView setImage:[mutableArray objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - Table View delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell =  (UITableViewCell *)[photosTypeTableView dequeueReusableCellWithIdentifier:cellIdentifier];

    cell.textLabel.text = [[self photosTypes] objectAtIndex:indexPath.row];
    [cell.textLabel setTextColor:[GVColor whiteColor]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroupType type;
    
    switch (indexPath.row) {
        case ALAssetsGroupLibrary:
            type = ALAssetsGroupLibrary;
            break;
        case ALAssetsGroupAlbum:
            type = ALAssetsGroupAlbum;
            break;
        case ALAssetsGroupEvent:
            type = ALAssetsGroupEvent;
            break;
        case ALAssetsGroupFaces:
            type = ALAssetsGroupFaces;
            break;
        case ALAssetsGroupSavedPhotos:
            type = ALAssetsGroupSavedPhotos;
            break;
        case ALAssetsGroupPhotoStream:
            type = ALAssetsGroupPhotoStream;
            break;
        default:
            type = ALAssetsGroupAll;
            break;
    }
    
    NSLog(@"you selected %@", [[self photosTypes] objectAtIndex:indexPath.row]);
    [photoSetLabel setText:[[self photosTypes] objectAtIndex:indexPath.row]];
    

    [mutableArray removeAllObjects]; //for emptying the photos array
    [photosCollectionView reloadData];
    [self getAllImages:type];
    
    //animation
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationDelegate:self];
    
    CGSize size = collectionContainerView.frame.size;
    CGPoint point = collectionContainerView.frame.origin;
    collectionContainerView.frame = CGRectMake(0, point.y, size.width, size.height);
    
    size = photosTypeTableView.frame.size;
    point = photosTypeTableView.frame.origin;
    photosTypeTableView.frame = CGRectMake(-self.view.frame.size.width, point.y, size.width, size.height);
    
    [UIView commitAnimations];
    
}


- (IBAction)btnAlbums:(id)sender {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationDelegate:self];
    
    CGSize size = photosTypeTableView.frame.size;
    CGPoint point = photosTypeTableView.frame.origin;
    photosTypeTableView.frame = CGRectMake(0, point.y, size.width, size.height);
    
    size = collectionContainerView.frame.size;
    point = collectionContainerView.frame.origin;
    collectionContainerView.frame = CGRectMake(self.view.frame.size.width, point.y, size.width, size.height);
    
    [UIView commitAnimations];
}
@end
