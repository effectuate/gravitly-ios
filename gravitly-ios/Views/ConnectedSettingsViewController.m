//
//  ConnectedSettingsViewController.m
//  gravitly-ios
//
//  Created by Mark Noquera on 12/17/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "ConnectedSettingsViewController.h"
#import "GVColor.h"


@interface ConnectedSettingsViewController ()

@end

@implementation ConnectedSettingsViewController

@synthesize imageView;
@synthesize label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)awakeFromNib {
    [label setTextColor:[GVColor textPaleGrayColor]];
    
}


@end
