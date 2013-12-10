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
        [self setFont:[UIFont fontWithName:kgvRobotoCondensedRegular size:kgvFontSize]];
        [self setTextColor:[GVColor textPaleGrayColor]];
        [self setValue:[GVColor textPaleGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        
        //[self setTextColor:[GVColor textPaleDarkSlateGrayColor]];
        //[self setValue:[GVColor textPaleDarkSlateGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    }
    return self;
}

- (void)setDefaultFontStyle {
    [self setFont:[UIFont fontWithName:kgvRobotoCondensedRegular size:kgvFontSize]];
    [self setTextColor:[GVColor textPaleGrayColor]];
    [self setValue:[GVColor textPaleGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    //[self setTextColor:[GVColor textPaleDarkSlateGrayColor]];
    //[self setValue:[GVColor textPaleDarkSlateGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
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
