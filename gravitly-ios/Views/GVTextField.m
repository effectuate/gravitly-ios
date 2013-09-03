//
//  GVTextField.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/3/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVTextField.h"

@implementation GVTextField

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
    // Our custom CALayer drawing will go here
    self = [super initWithCoder:coder];
    
    // Custom drawing methods
    if (self)
    {
        self = [super initWithFrame:self.frame];
        [self setFont:[UIFont fontWithName:@"RobotoCondensed-Regular" size:20.0]];
        [self setTextColor:[UIColor colorWithRed:26.0/255 green:26.0/255 blue:26.0/255 alpha:1.00f]];
        //[self setButtonColor:GVButtonColorBlue];
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
