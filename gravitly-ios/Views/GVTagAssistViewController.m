//
//  GVTagAssistViewController.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//
#define ACTIVITY_IMAGES @[@"weather.png", @"boat.png", @"snow.png", @"surfing.png", @"trail.png", @"wind.png", @"weather.png"]
#define TAG_ACTIVITY_LABEL 401
#define TAG_METADATA_TEXTFIELD 402
#define TAG_SHARE_BUTTON 403
#define TAG_LOCK_BUTTON 404

#import "GVTagAssistViewController.h"
#import "Activity.h"
#import "GVMetadataCell.h"
#import "GVActivityField.h"


@interface GVTagAssistViewController ()

@end

@implementation GVTagAssistViewController {
    NSArray *activities;
    NSMutableArray *activityButtons;
    Activity *selectedActivity;
    NSDictionary *enhancedMetadata;
}

@synthesize navBar;
@synthesize activityScrollView;

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
    [Activity findAllInBackground:^(NSArray *objects, NSError *error) {
        [activities arrayByAddingObjectsFromArray:objects];
        NSLog(@">>>>>>> %@", activities);
    }];
    [self createButtons];
    enhancedMetadata = [NSDictionary dictionary];
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
    float xPos = (idx + 1) * 11;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame: CGRectMake((100.0f * idx) + xPos, 0.0f, 100.0f, 100.0f)];
    int tag = idx;
    [button setTag:tag];
    
    GVLabel *label = [[GVLabel alloc] initWithFrame:CGRectMake((100.0f * idx) + xPos, 100.0f, 110.0f, 18.0f)];
    [label setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:14.0f];
    [label setText:activity.name];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    [scrollView setContentSize:CGSizeMake(activityScrollView.frame.size.width + 574, 0)];
    
    [button setImage:icon forState:UIControlStateNormal];
    [button setBackgroundColor:[GVColor buttonGrayColor]];
    [button addTarget:self action:@selector(activityButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [activityButtons addObject:button];
    [scrollView addSubview:button];
    [scrollView addSubview:label];
    [self.view setNeedsDisplay];
}

-(IBAction)activityButtonTapped:(UIButton *)sender {
    [self setSelectedActivity:sender.tag];
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
    NSLog(@"%@ ", selectedActivity.name);
    [self.view setNeedsDisplay];
}

#pragma mark - Enhanced metadata

- (NSArray *)enhanceMetadataArray {
    return enhancedMetadata.allKeys;
}

#pragma mark - Table View delegate and datasource


- (void)customiseFields: (UITableView *)tableView {
    [self customiseTable:tableView];
    [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 224.0f)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self enhanceMetadataArray].count;
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
    
    GVActivityField *actField = [[self enhanceMetadataArray] objectAtIndex:indexPath.row];
    
    UITextField *metadataTextField = cell.metadataTextfield;
    [metadataTextField setTag:indexPath.row];
    [metadataTextField setDelegate:self];
    
    //retrieval and replacing of values from tag format
    NSString *data = [enhancedMetadata objectForKey:actField.name];
    
    NSString *metadata = data ? [NSString stringWithFormat:@"%@", data] : @"";
    metadata = [actField.tagFormat stringByReplacingOccurrencesOfString:@"x" withString: metadata];
    
    [activityLabel setText:actField.name];
    [metadataTextField setText:metadata];
    metadataTextField.enabled = actField.editable ? YES : NO;
    
    //check if hash tag is on the array
    
//    if ([privateHashTagsKeys containsObject:actField.name]) {
//        [shareButton setImage:[UIImage imageNamed:@"check-disabled.png"] forState:UIControlStateNormal];
//    } else {
//        [shareButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
//    }
    
    //check if editable
    if (actField.editable) {
        [lockButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    } else {
        [lockButton setImage:[UIImage imageNamed:@"lock-close.png"] forState:UIControlStateNormal];
    }
    
    //set the property of cell
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setActivityField:actField];
    
    //add target when checked tapped
    [shareButton addTarget:self action:@selector(checkedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}



@end
