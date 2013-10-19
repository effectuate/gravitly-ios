//
//  GVMetadataCell.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 10/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVMetadataCell.h"

@implementation GVMetadataCell

@synthesize activityField;

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

@end
