//
//  GVTextView.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/10/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVTextView.h"

@implementation GVTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{

    self = [super initWithCoder:coder];
    
    if (self)
    {
        self = [super initWithFrame:self.frame];
        [self setFont:[UIFont fontWithName:kgvRobotoCondensedRegular size:kgvFontSize]];
        [self setTextColor:[GVColor textPaleGrayColor]];
        [self setBackgroundColor:[GVColor backgroundDarkBlueColor]];
    }
    return self;
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
