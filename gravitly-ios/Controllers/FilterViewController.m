//
//  FilterViewController.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 8/28/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

//TODO:standard size
#define STANDARD_SIZE 612.0f
#define TAG_MAGIC_NUMBER 10
#import "FilterViewController.h"
#import "GPUImage.h"
#import "CropPhotoViewController.h"
#import "AppDelegate.h"
#import "UIImage+Resize.h"
#import "ActivityViewController.h"

@interface FilterViewController ()

@property (nonatomic, getter = hasContrast) NSInteger contrast;
@property (nonatomic, getter = hasBlur) NSInteger blur;
@property (nonatomic, strong) GPUImageGaussianSelectiveBlurFilter *gaussianBlurFilter;
@property (nonatomic, strong) GPUImageToneCurveFilter *toneCurveFilter;
@property (nonatomic, strong) GPUImageContrastFilter *contrastFilter;
@property (nonatomic) NSUInteger rotationMultiplier;
@property (nonatomic, strong) NSMutableArray *filterButtons;

@property (weak, nonatomic) IBOutlet UIView *line;

@end

@implementation FilterViewController {
    NSArray *filters;
    NSArray *filterNames;
    UIImage *croppedImage;
    AppDelegate *appDelegate;
    NSMutableArray *filterButtons;
    int buttonSize;
}


@synthesize imageHolder;
@synthesize filterImageView;
@synthesize filterScrollView;
@synthesize zoomScale;
@synthesize cropperScrollView;
@synthesize navBar;
@synthesize filterUIView;
@synthesize meta;
@synthesize rotateButton;
@synthesize blurButton;
@synthesize contrastButton;
@synthesize contentOffset;
@synthesize contrast = _contrast;
@synthesize rotationMultiplier = _rotationMultiplier;
@synthesize gaussianBlurFilter = _gaussianBlurFilter, toneCurveFilter = _toneCurveFilter, contrastFilter = _contrastFilter;
@synthesize filterButtons = _filterButtons;

#pragma mark - Lazy Instantiations

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [appDelegate createFilterPlaceholders];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackButton:navBar];
    [self setProceedButton];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    filters = @[@"Normal",/*** @"1977", ***/ @"Brannan", @"Gotham", @"Hefe", /*** @"Lord Kelvin", ***/ @"Nashville", @"X-PRO II", /*** @"yellow-red", ***/ @"aqua", @"crossprocess"];
    
    filterNames = @[@"Normal", @"Filter 1", @"Filter 2", @"Filter 3", @"Filter 4", @"Filter 5", @"Filter 6", @"Filter 7"];
    
    [self.navigationItem setTitle:@"Edit"];
    
    filterImageView.contentMode = UIViewContentModeScaleAspectFit;
    filterImageView.userInteractionEnabled = YES;
    [filterImageView setImage:imageHolder];
    
    [self fixImageZoomScale];
    
    croppedImage = [croppedImage resizeImageToSize:CGSizeMake(STANDARD_SIZE, STANDARD_SIZE)];
    
    [self setNavigationBar:navBar title:navBar.topItem.title];
    
    
    //image from link works here..
    /*
    NSURL *url = [NSURL URLWithString:@"http://s3.amazonaws.com/gravitly.uploads.dev/e97979b8-6502-4f2b-944f-8313b4bae9ac.jpeg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    filterImageView.image = image;
    */
    
    
    filterImageView.image = croppedImage;

    
    filterScrollView.translatesAutoresizingMaskIntoConstraints= NO;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.filterButtons = [[NSMutableArray alloc] init];
    
    
    NSLog(@"%@ %@", meta.coordinate, meta.altitude);
    

    if (IS_IPHONE_5) {
        NSLog(@"iphone 5");
        buttonSize = 100;
        [filterScrollView setContentSize:CGSizeMake(5, 0)];
        [filterScrollView setFrame:CGRectMake(filterScrollView.frame.origin.x, filterScrollView.frame.origin.y + 15, CGRectGetWidth(filterScrollView.frame), CGRectGetHeight(filterScrollView.frame))];

    } else {
        //136 40
        [rotateButton setFrame:CGRectMake(45, 370, 22, 20)];
        [blurButton setFrame:CGRectMake(145, 10, 14, 22)];
        [contrastButton setFrame:CGRectMake(240, 370, 25, 25)];
       
        [filterUIView setFrame:CGRectMake(0, 360, 322, 200)];
        //[contrastButton setFrame:CGRectSetY(contrastButton.frame, 325)];
        //[blurButton setFrame:CGRectSetY(blurButton.frame, 325)];
        //[rotateButton setFrame:CGRectSetY(rotateButton.frame, 325)];
        //[filterUIView setFrame:CGRectSetY(filterUIView.frame, 315)];
        [cropperScrollView setFrame:CGRectMake(10, 53, 300, 300)];
    
        buttonSize = 60;
        [self.line setHidden:YES];
        
        [filterScrollView setFrame:CGRectMake(filterScrollView.frame.origin.x, filterScrollView.frame.origin.y - 25, CGRectGetWidth(filterScrollView.frame), CGRectGetHeight(filterScrollView.frame))];
        
        NSLog(@"iphone 4");
    }
    
    [self createButtons];

    
}


#pragma mark - Activity Buttons

- (void)createButtons {

    for (int i = 0; i < filters.count; i++) {
        [self createButtonForFilter: i];
    }
}

- (void)createButtonForFilter:(int) idx {
    float xPos = (idx + 1) * 11;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSData *data = [appDelegate.filterPlaceholders objectForKey:[filters objectAtIndex:idx]];
    [button setFrame: CGRectMake((buttonSize * idx) + xPos, 0.0f, buttonSize, buttonSize)];
    if (idx == 0) {
        UIImage *img = [UIImage imageNamed:@"filter-placeholder.png"];
        [button setImage:img forState:UIControlStateNormal];
    } else {
        [button setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    }
    
    
    int tag = idx + TAG_MAGIC_NUMBER;
    [button setTag:tag];
    
    GVLabel *label = [[GVLabel alloc] initWithFrame:CGRectMake((buttonSize * idx) + xPos, buttonSize, buttonSize, 18.0f)];
    [label setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:14.0f];
    [label setText:filterNames[idx]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    float multiplier = 12.5f;
    CGSize newSize = CGSizeMake((filterScrollView.contentSize.width + buttonSize) + multiplier, filterScrollView.contentSize.height);
    [filterScrollView setContentSize:newSize];
    
    
    [button setBackgroundColor:[GVColor buttonGrayColor]];
    [button addTarget:self action:@selector(filterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [filterButtons addObject:button];
    [filterScrollView addSubview:button];
    [filterScrollView addSubview:label];
    [self.view setNeedsDisplay];

}


-(IBAction)filterButtonTapped:(UIButton *)sender {
    
    for (int i = 0; i < filters.count; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag: i + TAG_MAGIC_NUMBER];
        NSLog(@" TAG %i", i + TAG_MAGIC_NUMBER);
        
        [button.layer setBorderColor: [UIColor clearColor].CGColor];
        [button.layer setBorderWidth: 0.0];
    }
    
    [sender.layer setBorderColor:[[GVColor buttonBlueColor] CGColor]];
    [sender.layer setBorderWidth: 2.0];
    
    GPUImageToneCurveFilter *selectedFilter;
    NSString *filterString = [filters objectAtIndex:(sender.tag - TAG_MAGIC_NUMBER)];
    
    if ((sender.tag - TAG_MAGIC_NUMBER) != 0) {
        selectedFilter = [[GPUImageToneCurveFilter alloc] initWithACV:filterString];
        self.toneCurveFilter = selectedFilter;
        [self applyEffects];
    } else {
        self.toneCurveFilter = nil;
        [self applyEffects];
    }

}


#pragma mark - Image manipulations

- (void)fixImageZoomScale {
    CGSize origSize = filterImageView.frame.size;
    
    filterImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, zoomScale, zoomScale);
    [cropperScrollView setZoomScale:zoomScale];
    
    cropperScrollView.contentSize = origSize;
    [cropperScrollView setContentOffset:contentOffset];
    
    UIGraphicsBeginImageContextWithOptions(cropperScrollView.contentSize, NO, 0.0);
    {
        CGPoint savedContentOffset = cropperScrollView.contentOffset;
        CGRect savedFrame = cropperScrollView.frame;
        cropperScrollView.contentOffset = CGPointZero;
        cropperScrollView.frame = CGRectMake(0, 0, cropperScrollView.contentSize.width, cropperScrollView.contentSize.height);
        [cropperScrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
        cropperScrollView.contentOffset = savedContentOffset;
        cropperScrollView.frame = savedFrame;
    }   
    UIGraphicsEndImageContext();
    
    if (croppedImage != nil) {
        filterImageView.image = croppedImage;
        filterImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushActivityViewController {
    ActivityViewController *avc = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityViewController"];
    
    UIImage *finalImage = [[UIImage alloc] init];
    
    UIGraphicsBeginImageContextWithOptions(cropperScrollView.contentSize, NO, 0.0);
    {
        CGPoint savedContentOffset = cropperScrollView.contentOffset;
        CGRect savedFrame = cropperScrollView.frame;
        cropperScrollView.contentOffset = CGPointZero;
        cropperScrollView.frame = CGRectMake(0, 0, cropperScrollView.contentSize.width, cropperScrollView.contentSize.height);
        [cropperScrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        finalImage = UIGraphicsGetImageFromCurrentImageContext();
        cropperScrollView.contentOffset = savedContentOffset;
        cropperScrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    [avc setImageHolder:finalImage];
    NSLog(@"metatatata %@ %@ %@", meta.longitude, meta.latitude, meta.altitude);
    [avc setMeta:meta];
    [self.navigationController pushViewController:avc animated:YES];
}


- (IBAction)applyFilter:(UIButton *)sender {
    //NSString *buttonTitle = [];//sender.titleLabel.text;
    
    /*
    if ([buttonTitle isEqualToString:@"B&W"]) {
        filterImageView.image = [filterImageView.image saturateImage:0 withContrast:1.05];
    }
    */
    
//    for (int x = 1; x < filters.count; x++) {
//        [sender.layer setBorderColor: nil];
//        [sender.layer setBorderWidth: 0.0];
//    }
//    
//
    
    for (UIButton *f in self.filterButtons) {
        [f.layer setBorderColor: [UIColor clearColor].CGColor];
        [f.layer setBorderWidth: 0.0];
    }
    
    [sender.layer setBorderColor:[[GVColor buttonBlueColor] CGColor]];
    [sender.layer setBorderWidth: 2.0];
    
    GPUImageToneCurveFilter *selectedFilter;
    UIImage *filteredImage =[[UIImage alloc] init];
    NSString *filterString = [filters objectAtIndex:(sender.tag - TAG_MAGIC_NUMBER)];
    
    if ((sender.tag - TAG_MAGIC_NUMBER) != 0) {
        selectedFilter = [[GPUImageToneCurveFilter alloc] initWithACV:filterString];
        self.toneCurveFilter = selectedFilter;
        [self applyEffects];
    } else {
        self.toneCurveFilter = nil;
        [self applyEffects];
    }
    
}


- (IBAction)applyContrast:(id)sender {
    if (self.hasContrast) {
        self.contrastFilter = nil;
        [self setContrast:0];
    } else {
        self.contrastFilter = [[GPUImageContrastFilter alloc] init];
        [self.contrastFilter setContrast:1.5f];
        [self setContrast:1];
    }
    [self applyEffects];
}

- (IBAction)rotate:(id)sender {
    float degrees = (self.rotationMultiplier + 1) * 90.0f;
    filterImageView.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);
    self.rotationMultiplier++;
}

- (IBAction)applyBlur:(id)sender {
    if (self.hasBlur) {
        self.gaussianBlurFilter = nil;
        [self setBlur:0];
    } else {
        self.gaussianBlurFilter = [GPUImageGaussianSelectiveBlurFilter new];
        [self.gaussianBlurFilter setBlurSize:2.0];
        [self.gaussianBlurFilter setExcludeCircleRadius:120.0/320.0];
        [self.gaussianBlurFilter setExcludeCirclePoint:CGPointMake(0.5f, 0.5f)];
        [self setBlur:1];
    }
    [self applyEffects];
}

#pragma mark - GPUImage manipulations

- (void)applyEffects {
    [self resetFilter];
    if (self.gaussianBlurFilter) {
        filterImageView.image = [self.gaussianBlurFilter imageByFilteringImage:filterImageView.image];
    }
    if (self.toneCurveFilter) {
        filterImageView.image = [self.toneCurveFilter imageByFilteringImage:filterImageView.image];
    }
    if (self.contrastFilter) {
        filterImageView.image = [self.contrastFilter imageByFilteringImage:filterImageView.image];
    }
}

- (IBAction)reset:(id)sender {
    [self resetFilter];
}

-(void)resetFilter {
    filterImageView.image = croppedImage;
}

#pragma mark - Nav bar button methods

/*- (void)setBackButton {
    
    UIButton *backButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"carret.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    [navBar.topItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
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
}


- (void)proceedButtonTapped:(id)sender
{
    [self performSelector:@selector(pushActivityViewController) withObject:nil];
}


@end
