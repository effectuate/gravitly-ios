//
//  MainMenuViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define TAG_FEED_IMAGE_VIEW 500
#define TAG_FEED_CAPTION_TEXT_VIEW 501
#define TAG_FEED_USERNAME_LABEL 502
#define TAG_FEED_DATE_CREATED_LABEL 503
#define TAG_FEED_LOCATION_LABEL 504
#define TAG_FEED_GEO_LOC_LABEL 505
#define TAG_FEED_USER_IMAGE_VIEW 506

#import "MainMenuViewController.h"
#import "CropPhotoViewController.h"
#import "LogInViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking.h>
#import "Feed.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface MainMenuViewController ()

@property (nonatomic) UIImage *capturedImaged;
@property (nonatomic) UIImagePickerController *picker;

@end

@implementation MainMenuViewController {
    NSMutableArray *feeds;
    AppDelegate *appDelegate;
}

@synthesize photoFeedTableView;
@synthesize navBar;
/*@synthesize overlayView;
 @synthesize cropperView;*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    feeds = [[NSMutableArray alloc] init];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.feedImages = [[NSCache alloc] init];
    [self getFeeds];
    [self setNavigationBar:navBar title:[PFUser currentUser].username];
    [self setSettingsButton];
    [self setRightBarButtons];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)btnGrabIt:(id)sender {
    NSLog(@"taking picture...");
    [self.picker takePicture];
}

- (IBAction)btnCameraRoll:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker = picker;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)btnGallery:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker = picker;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)btnLogout:(id)sender {
    LogInViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
    [self presentViewController:lvc animated:YES completion:nil];
    
    //[self presentViewController:lvc animated:YES completion:nil];
}


- (void)viewDidAppear:(BOOL)animated {
    //[super viewDidAppear:YES];
    NSLog(@"3 did appear main menu");
}

- (IBAction)cameraTab:(id)sender {
    [self.tabBarController setSelectedIndex:1];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    /*NSLog(@"taking picture --->");
     
     UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
     
     
     CALayer *layer = [CALayer layer];
     layer.frame = cropperView.frame;
     
     
     self.capturedImaged = image;
     [self finishAndUpdate];*/
}


-(void) finishAndUpdate {
    /*[self dismissViewControllerAnimated:YES completion:NULL];
     NSLog(@"todo.. go to cropping and filter page now..");
     CropPhotoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CropPhoto"];
     vc.imageHolder = self.capturedImaged;
     [self.navigationController pushViewController:vc animated:YES];*/
}

- (void)getLatestPhotoFromGallery {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // be sure to filter the group so you only get photos
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                ALAssetRepresentation *repr = [result defaultRepresentation];
                UIImage *img = [UIImage imageWithCGImage:[repr fullResolutionImage]];
                NSLog(@"---------------> getting latest image %@", img);
                
                *stop = YES;
            }
        }];
        *stop = NO;
    } failureBlock:^(NSError *error) {
        NSLog(@"fail *error");
    }];
}

#pragma mark - Table view delegates

- (void)getFeeds {
    [Feed getFeeds:^(NSArray *objects, NSError *error) {
        [feeds addObjectsFromArray:objects];
        [photoFeedTableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = (UITableViewCell *)[photoFeedTableView dequeueReusableCellWithIdentifier:@"PhotoFeedCell"];
    
    if (cell == nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PhotoFeedCell" owner:self options:nil] objectAtIndex:0];
    }
    
    //UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:TAG_FEED_USERNAME_LABEL];
    UITextView *captionTextView = (UITextView *)[cell viewWithTag:TAG_FEED_CAPTION_TEXT_VIEW];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:TAG_FEED_DATE_CREATED_LABEL];
    UILabel *geoLocLabel = (UILabel *)[cell viewWithTag:TAG_FEED_GEO_LOC_LABEL];
    UILabel *locationLabel = (UILabel *)[cell viewWithTag:TAG_FEED_LOCATION_LABEL];
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
    UIImageView *userImgView = (UIImageView *)[cell viewWithTag:TAG_FEED_USER_IMAGE_VIEW];
    
    //rounded corner
    CALayer * l = [userImgView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:userImgView.frame.size.height / 2];
    
    
    [imgView setImage:[UIImage imageNamed:@"placeholder.png"]];
    
    Feed *feed = [feeds objectAtIndex:indexPath.row];
    //[self getImageFromFeed:feed atIndex:indexPath];
    
    
    ////
    
    dispatch_queue_t queue = dispatch_queue_create("ly.gravit.DownloadingFeedImage", NULL);
    dispatch_async(queue, ^{
        
        NSLog(@">>>> get image %@", [appDelegate.feedImages objectForKey:feed.imageFileName] ? @"YES" : @"NO");
        
        if (![[appDelegate.feedImages objectForKey:feed.imageFileName] length]) {
            NSString *imagepath = [NSString stringWithFormat:@"http://s3.amazonaws.com/gravitly.uploads.dev/%@", feed.imageFileName];
            NSURL *url = [NSURL URLWithString:imagepath];
            NSData *data = [NSData dataWithContentsOfURL:url];
            [appDelegate.feedImages setObject:data forKey:feed.imageFileName];
            
            NSLog(@"Wala");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *data = [appDelegate.feedImages objectForKey:feed.imageFileName];
            UIImage *image = [[UIImage alloc] initWithData:data];
            UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
            [imgView setImage:image];
            
            //NSLog(@"Meron");
        });
    });
    
    
    ////
    
    
    
    
    NSString *tagString = @"";
    for (NSString *tag in feed.hashTags) {
        tagString = [NSString stringWithFormat:@"%@ #%@", tagString, tag];
    }
    
    [usernameLabel setText:feed.user];
    [captionTextView setText:[NSString stringWithFormat:@"%@ %@", feed.caption, tagString]];
    [geoLocLabel setText:[NSString stringWithFormat:@"%.4f %.4f", feed.latitude, feed.longitude]];
    [locationLabel setText:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateLabel setText:[dateFormatter stringFromDate:feed.dateUploaded]];
    
    //[photoFeedTableView reloadData];
    
    return cell;
}

- (void)getImageFromFeed: (Feed *)feed atIndex:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = (UITableViewCell *)[photoFeedTableView cellForRowAtIndexPath:indexPath];
    UITextView *captionTextView = (UITextView *)[cell viewWithTag:TAG_FEED_CAPTION_TEXT_VIEW];
    
    NSLog(@"<><><>><<<<>>>>>> %i %@", indexPath.row, captionTextView.text);
    
    dispatch_queue_t queue = dispatch_queue_create("ly.gravit.DownloadingFeedImage", NULL);
    dispatch_async(queue, ^{
        
        NSLog(@">>>> get image %@", [appDelegate.feedImages objectForKey:feed.imageFileName] ? @"YES" : @"NO");
        
        if (![[appDelegate.feedImages objectForKey:feed.imageFileName] length]) {
            NSString *imagepath = [NSString stringWithFormat:@"http://s3.amazonaws.com/gravitly.uploads.dev/%@", feed.imageFileName];
            NSURL *url = [NSURL URLWithString:imagepath];
            NSData *data = [NSData dataWithContentsOfURL:url];
            [appDelegate.feedImages setObject:data forKey:feed.imageFileName];
            
            NSLog(@"Wala");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *data = [appDelegate.feedImages objectForKey:feed.imageFileName];
            UIImage *image = [[UIImage alloc] initWithData:data];
            UIImageView *imgView = (UIImageView *)[cell viewWithTag:TAG_FEED_IMAGE_VIEW];
            [imgView setImage:image];
            
            //NSLog(@"Meron");
        });
    });
}


#pragma mark - Nav bar button methods

- (void)setSettingsButton {
    UIButton *backButton = [self createButtonWithImageNamed:@"settings.png"];
    [backButton addTarget:self action:@selector(btnLogout:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navBar.topItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
}

- (void)setRightBarButtons {
    UIButton *listButton = [self createButtonWithImageNamed:@"list.png"];
    //[listButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *collectionButton = [self createButtonWithImageNamed:@"collection.png"];
    //[collectionButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *mapPinButton = [self createButtonWithImageNamed:@"map-pin.png"];
    //[mapPinButton addTarget:self action:@selector(presentMap:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *buttons = @[[[UIBarButtonItem alloc] initWithCustomView:mapPinButton], [[UIBarButtonItem alloc] initWithCustomView:listButton],
                         [[UIBarButtonItem alloc] initWithCustomView:collectionButton]];
    
    [self.navBar.topItem setRightBarButtonItems:buttons];
}


@end
