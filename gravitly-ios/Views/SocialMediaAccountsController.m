//
//  SocialMediaAccountsView.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "SocialMediaAccountsController.h"

@implementation SocialMediaAccountsController

@synthesize delegate;
@synthesize label;
@synthesize facebookButton;
@synthesize twitterButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    //if ([delegate respondsToSelector:@selector(socialMediaAccountsViewLabel:)]) {
    //}
    [self setBackgroundColor:[GVColor backgroundDarkBlueColor]];
    [self.label setLabelStyle:GVRobotoCondensedRegularPaleGrayColor size:kgvFontSize];
    [delegate socialMediaAccountsView:self];
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
