//
//  PhotoFeedViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 10/9/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "PhotoFeedViewController.h"
#import <Parse/Parse.h>
#import <AFNetworking.h>

//define tags and xib here
#define PHOTO_CELL @"PhotoFeedCell"
#define photo_tag 500

@interface PhotoFeedViewController ()

@end

@implementation PhotoFeedViewController

@synthesize photoTableView;
@synthesize photos;

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
	// Do any additional setup after loading the view.
    
    //load cell here
    [self.photoTableView registerNib:[UINib nibWithNibName:PHOTO_CELL bundle:nil] forHeaderFooterViewReuseIdentifier:PHOTO_CELL];
    //get parse..
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    //[query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"photssss");
            self.photos = objects;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"photssss 2222");
            [self.photoTableView reloadData];
            //[self removeProgressHUD:self.tableView];
        });
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//====== tableview controller.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"countss >>> %i", self.photos.count);
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.photoTableView dequeueReusableCellWithIdentifier:PHOTO_CELL];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:PHOTO_CELL];
    }
    
    PFObject *element = [photos objectAtIndex:indexPath.row];
    UIImageView *photoImage = (UIImageView *)[cell viewWithTag:photo_tag];
    
    NSString *imagepath = [NSString stringWithFormat:@"http://s3.amazonaws.com/gravitly.uploads.dev/%@",
                           [element objectForKey:@"filename"]];
    
    /*
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:imagepath]];
    [client getPath:imagepath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *imageData = [UIImage imageNamed:imagepath];
        NSLog(@"photo data >> %@", imageData);
        UIImage *pugs = [UIImage imageWithData:imageData];
        
        photoImage.image = pugs;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error");
    }];
     */
    
    //http://stackoverflow.com/questions/2782454/can-i-load-a-uiimage-from-a-url
    //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:
     //                                        [NSURL URLWithString:imagepath]]];
    
    //http://stackoverflow.com/questions/1760857/iphone-how-to-get-a-uiimage-from-a-url
    NSURL *url = [NSURL URLWithString:imagepath];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    photoImage.image = image;
    
    NSLog(@"image? >>> %@", image);
    NSLog(@"image path >> %@" ,imagepath);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 170;
}
//=======

@end
