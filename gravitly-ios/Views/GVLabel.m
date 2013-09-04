//
//  CPLabel.m
//  CPScentControl
//
//  Created by Eli Dela Cruz on 7/30/13.
//  Copyright (c) 2013 DYNOBJX. All rights reserved.
//

#import "GVLabel.h"

@implementation GVLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setLabelStyle: (GVLabelStyle)labelStyle size:(float)size {
    switch (labelStyle) {
        case GVRobotoCondensedRegularPaleGrayColor: {
            [self setTextColor:[GVColor textPaleGrayColor]];
            [self setFont:[UIFont fontWithName:kgvRobotoCondensedRegular size:size]];
            break;
        }
        case GVRobotoCondensedBoldPaleGrayColor: {
            UIColor *color = [GVColor textPaleGrayColor];
            [self setTextColor:color];
            [self setFont:[UIFont fontWithName:kgvRobotoCondensedBold size:size]];
            break;
        }
        default:
            break;
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
