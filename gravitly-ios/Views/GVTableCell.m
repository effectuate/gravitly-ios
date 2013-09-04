//
//  GVCell.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/3/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVTableCell.h"
#import "GVColor.h"

@implementation GVTableCell

@synthesize imageView;
@synthesize textField;

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
    [textField setTextColor:[GVColor textPaleGrayColor]];
}

@end
