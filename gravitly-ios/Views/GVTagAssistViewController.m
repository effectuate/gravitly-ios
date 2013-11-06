//
//  GVTagAssistViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define FORBID_FIELDS_ARRAY @[@"community", @"region", @"country", @"Elevation M", @"Elevation F", @"ActivityName"]
#define ADDITIONAL_FIELDS_ARRAY @[@"Named Location 2"]

#define BASE_URL @"http://webapi.webnuggets.cloudbees.net"
#define ENDPOINT_ENVIRONMENT @"/environment/%@/%f,%f"

#define ACTIVITY_IMAGES @[@"weather.png", @"boat.png", @"snow.png", @"surfing.png", @"trail.png", @"wind.png", @"weather.png"]

#define TAG_ACTIVITY_LABEL 401
#define TAG_METADATA_TEXTFIELD 402
#define TAG_SHARE_BUTTON 403
#define TAG_LOCK_BUTTON 404

#define ACTIVITY_BUTTON_WIDTH 70
#define ACTIVITY_MULTIPLIER 10

#import "GVTagAssistViewController.h"
#import "Activity.h"
#import "GVMetadataCell.h"
#import "GVActivityField.h"
#import "GVWebHelper.h"

@interface GVTagAssistViewController ()

@end

@implementation GVTagAssistViewController {
    NSArray *activities;
    NSMutableArray *activityButtons;
    Activity *selectedActivity;
    NSMutableDictionary *enhancedMetadataDictionary;
    JSONHelper *jsonHelper;
    NSMutableArray *activityFieldsArray;
}

@synthesize navBar;
@synthesize activityScrollView;
@synthesize tagsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)activityImages {
    return ACTIVITY_IMAGES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setNavigationBar:navBar title:self.navBar.topItem.title];
    [self setBackButton:navBar];
    [self setProceedButton:navBar];
    
    activities = [NSArray array];
    [Activity findAllInBackground:^(NSArray *objects, NSError *error) {
        activities = objects;
        NSLog(@"--------lettuce %@", objects);
        [self createButtons];
    }];
    
    //collections
    activityFieldsArray = [[NSMutableArray alloc] init];
    enhancedMetadataDictionary = [[NSMutableDictionary alloc] init];
    activityButtons = [NSMutableArray array];
    
    jsonHelper = [[JSONHelper alloc] init];
    [jsonHelper setDelegate:self];
    
    [tagsTableView setDataSource:self];
    [tagsTableView setDelegate:self];
    
}

#pragma mark - initialization

- (void)combineEnhancedMetadata {
    activityFieldsArray = [[NSMutableArray alloc] init];
    NSArray *allKeys = [enhancedMetadataDictionary allKeys]; //from web json
    
    //additional fields
    for (NSString *act in [self additional]) {
        NSString *key = act;
        [enhancedMetadataDictionary setObject:@"" forKey: key];
        GVActivityField *actField = [[GVActivityField alloc] init];
        actField.name = key;
        actField.tagFormat = @"#x";
        actField.editable = 1;
        [activityFieldsArray addObject:actField];
    }
    
    GVWebHelper *helper = [[GVWebHelper alloc] init];
    for (GVActivityField *actField in [helper fieldsForActivity:selectedActivity.name]) {
        BOOL isNotForbidden = ![self.forbid containsObject:actField.name];
        BOOL isAbsentOnEnhanced = ![allKeys containsObject:actField.name];
        
        if (isNotForbidden) {
            if (isAbsentOnEnhanced) { //present in mapping absent in web json
                [enhancedMetadataDictionary setObject:@"" forKey:actField.name.description];
            }
            [activityFieldsArray addObject:actField];
        }   
    }
    
    //setting of activity name
    [enhancedMetadataDictionary setObject:selectedActivity.name forKey:@"ActivityName"];
}

- (NSArray *)forbid {
    return (NSArray *)FORBID_FIELDS_ARRAY;
}

- (NSArray *)additional {
    return (NSArray *)ADDITIONAL_FIELDS_ARRAY;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Navigation buttons

- (void)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setProceedButton: (UINavigationBar *)_navBar {
    UIButton *proceedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [proceedButton setImage:[UIImage imageNamed:@"check-big.png"] forState:UIControlStateNormal];
    [proceedButton addTarget:self action:@selector(proceedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [proceedButton setFrame:CGRectMake(0, 0, 32, 32)];
    
    [_navBar.topItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:proceedButton]];
}

- (void)proceedButtonTapped:(id)sender
{
    NSLog(@"-----------> SEARCH!");
}

#pragma mark - Creating Activity Buttons

- (void)createButtons {
    for (int i = 0; i < activities.count; i++) {
        [self createButtonForActivity:[activities objectAtIndex:i] atIndex:i inScrollView:activityScrollView];
    }
}

- (void)createButtonForActivity:(Activity *)activity atIndex:(int)idx inScrollView:(UIScrollView *)scrollView {
    UIImage *icon = [UIImage imageNamed:[[self activityImages] objectAtIndex:idx]];
    
    float multiplier = ACTIVITY_MULTIPLIER;
    
    float xPos = (idx + 1) * multiplier;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame: CGRectMake((ACTIVITY_BUTTON_WIDTH * idx) + xPos, 0.0f, ACTIVITY_BUTTON_WIDTH, ACTIVITY_BUTTON_WIDTH)];
    int tag = idx;
    [button setTag:tag];
    
    GVLabel *label = [[GVLabel alloc] initWithFrame:CGRectMake((ACTIVITY_BUTTON_WIDTH * idx) + xPos, ACTIVITY_BUTTON_WIDTH, ACTIVITY_BUTTON_WIDTH+ multiplier, 18.0f)];
    [label setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:14.0f];
    [label setText:activity.name];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    multiplier = idx == activities.count -1 ? multiplier : multiplier + 2;
    
    CGSize newSize = CGSizeMake((scrollView.contentSize.width + ACTIVITY_BUTTON_WIDTH) + multiplier, scrollView.contentSize.height);
    
    [scrollView setContentSize:newSize];
    
    [button setImage:icon forState:UIControlStateNormal];
    [button setBackgroundColor:[GVColor buttonGrayColor]];
    [button addTarget:self action:@selector(activityButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [activityButtons addObject:button];
    [scrollView addSubview:button];
    [scrollView addSubview:label];
    [self.view setNeedsDisplay];
}

-(void)setSelectedActivity:(int)idx {
    for (UIButton *button in activityButtons) {
        if (button.tag == idx) {
            [button setBackgroundColor:[GVColor buttonBlueColor]];
            selectedActivity = [activities objectAtIndex:idx];
        } else {
            [button setBackgroundColor:[GVColor buttonGrayColor]];
        }
        
    }
    NSLog(@"%@ %i", selectedActivity.name, idx);
    [self.view setNeedsDisplay];
}

#pragma mark - Table View delegate and datasource


- (void)customiseFields: (UITableView *)tableView {
    [self customiseTable:tableView];
    [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 224.0f)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  activityFieldsArray.count;//enhancedMetadataDictionary.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    GVMetadataCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSLog(@">>>>>>>>> %i", indexPath.row);
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"MetadataCell" owner:self options:nil];
        cell = (GVMetadataCell *)[nibs objectAtIndex:0];
    }
    
    GVLabel *activityLabel = (GVLabel *)[cell viewWithTag:TAG_ACTIVITY_LABEL];
    [activityLabel setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize16];
    UIButton *shareButton = (UIButton *)[cell viewWithTag:TAG_SHARE_BUTTON];
    UIButton *lockButton = (UIButton *)[cell viewWithTag:TAG_LOCK_BUTTON];
    
    GVActivityField *actField = [activityFieldsArray objectAtIndex:indexPath.row];
    
    UITextField *metadataTextField = cell.metadataTextfield;
    [metadataTextField setTag:indexPath.row];
    [metadataTextField setDelegate:self];
    
    //retrieval and replacing of values from tag format
    NSString *data = [enhancedMetadataDictionary objectForKey:actField.name];
    
    NSString *metadata = data ? [NSString stringWithFormat:@"%@", data] : @"";
    metadata = [actField.tagFormat stringByReplacingOccurrencesOfString:@"x" withString: metadata];
    [metadata stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [activityLabel setText:actField.name];
    [metadataTextField setText:metadata];
    
    
//    metadataTextField.enabled = actField.editable ? YES : NO;
    
    //check if hash tag is on the array
    
//    if ([privateHashTagsKeys containsObject:actField.name]) {
//        [shareButton setImage:[UIImage imageNamed:@"check-disabled.png"] forState:UIControlStateNormal];
//    } else {
//        [shareButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
//    }
    
    //check if editable
    [lockButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    
    //set the property of cell
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setActivityField:actField];
    
    //add target when checked tapped
    [shareButton addTarget:self action:@selector(checkedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - JSON Helper delegates

-(void)didReceiveJSONResponse:(NSDictionary *)_json {
    NSArray *allKeys = [[_json objectForKey:selectedActivity.name] allKeys];
    
    NSLog(@">>> Enhanced Metadata Count: %i", allKeys.count);

    
    enhancedMetadataDictionary = [[_json objectForKey:selectedActivity.name] mutableCopy];
    [self combineEnhancedMetadata];
    [tagsTableView reloadData];
    
    NSLog(@">>>>>>>>> new enhance %i act fields %i", enhancedMetadataDictionary.allKeys.count, activityFieldsArray.count);
//    [hud removeFromSuperview];
}

-(void)didNotReceiveJSONResponse:(NSError *)error {
    NSLog(@"%@", error.debugDescription);
    enhancedMetadataDictionary = nil;
    [tagsTableView reloadData];
}


#pragma mark - activity

-(IBAction)activityButtonTapped:(UIButton *)sender {
    [self setSelectedActivity:sender.tag];
    NSString *endpoint = [NSString stringWithFormat:ENDPOINT_ENVIRONMENT, selectedActivity.objectId, [self getCurrentLocation].coordinate.latitude, [self getCurrentLocation].coordinate.longitude];
    NSLog(@">>> %@", endpoint);
    
    //hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText = @"Retrieving Metadata";
    [jsonHelper requestJSON:nil withBaseURL:BASE_URL withEndPoint:endpoint];
}

#pragma mark - core location

-(CLLocation *)getCurrentLocation {
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    [manager setDesiredAccuracy:kCLLocationAccuracyBest];
    [manager startUpdatingLocation];
    
    return manager.location;
}

@end
