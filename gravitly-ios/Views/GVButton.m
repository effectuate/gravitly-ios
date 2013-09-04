//
//  CPButton.m
//  CPScentControl
//
//  Created by Eli Dela Cruz on 8/7/13.
//  Copyright (c) 2013 DYNOBJX. All rights reserved.
//

#import "GVButton.h"

@implementation GVButton {
    UIColor *backgroundColor;
    UIColor *highlightColor;
    CGColorRef bgColor;
}

@synthesize backgroundLayer = _backgroundLayer;
@synthesize highlightLayer = _highlightLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
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
        [self.titleLabel setFont:[UIFont fontWithName:@"RobotoCondensed-Regular" size:20.0]];
        [self setTitleColor:[UIColor colorWithRed:26.0/255 green:26.0/255 blue:26.0/255 alpha:1.00f] forState:UIControlStateNormal];
        [self setButtonColor:GVButtonColorBlue];
    }
    return self;
}

- (id)initWithColor:(GVButtonColor)color
{
    
    self = [super initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    UIColor *uiColor = [[UIColor alloc] init];
    UIColor *hlColor = [[UIColor alloc] init];
    
    if (color == GVButtonColorBlue) {
        uiColor = [UIColor colorWithRed:52.0/255 green:152.0/255 blue:219.0/255 alpha:1.00f];
        hlColor = uiColor;
    } else if (color == GVButtonColorGray) {
        uiColor = [UIColor grayColor];
        hlColor = uiColor;
    } else {
        uiColor = [UIColor grayColor];
        hlColor = uiColor;
    }
    
    [self drawButton];
    [self drawBackground];
    [self drawHighlight];
    
    return (self);
}

- (void)drawButton
{
    // Get the root layer
    CALayer *layer = self.layer;
    layer.cornerRadius = 5.0f;
}

- (void)drawBackground
{
    if (!_backgroundLayer)
    {
        // Instantiate the backgroundLayer layer
        _backgroundLayer = [CALayer layer];
        _backgroundLayer.backgroundColor = backgroundColor.CGColor;
        //_backgroundLayer.cornerRadius = 5.0f;
        
        [self.layer insertSublayer:_backgroundLayer atIndex:0];
    } else {
        _backgroundLayer = [self.layer.sublayers objectAtIndex:0];
        _backgroundLayer.backgroundColor = backgroundColor.CGColor;
        //_backgroundLayer.cornerRadius = 5.0f;
    }
}

- (void)drawHighlight
{
    if (!_highlightLayer)
    {
        // Instantiate the backgroundLayer layer
        _highlightLayer = [CALayer layer];
        _highlightLayer.backgroundColor = highlightColor.CGColor;
        //_highlightLayer.cornerRadius = 5.0f;
        
        [self.layer insertSublayer:_highlightLayer atIndex:1];
    } else {
        _highlightLayer = [self.layer.sublayers objectAtIndex:1];
        _highlightLayer.backgroundColor = highlightColor.CGColor;
        //_highlightLayer.cornerRadius = 5.0f;
    }
}

- (void)layoutSubviews
{
    _backgroundLayer.frame = self.bounds;
    _highlightLayer.frame = self.bounds;
    _highlightLayer.hidden = YES;
    [super layoutSubviews];
}

- (void)setHighlighted:(BOOL)highlighted
{
    // Disable implicit animations
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    // Hide/show inverted gradient
    _highlightLayer.hidden = !highlighted;
    
    [CATransaction commit];
    
    //[super setHighlighted:highlighted];
}

-(void)setButtonColor:(GVButtonColor)color {
    
    UIColor *uiColor = [[UIColor alloc] init];
    UIColor *hlColor = [[UIColor alloc] init];
    
    if (color == GVButtonColorBlue) {
        uiColor = [UIColor colorWithRed:52.0/255 green:152.0/255 blue:219.0/255 alpha:1.00f];
        hlColor = uiColor;
    } else if (color == GVButtonColorGray) {
        uiColor = [UIColor grayColor];
        hlColor = uiColor;
    } else {
        uiColor = [UIColor grayColor];
        hlColor = uiColor;
    }
    
    backgroundColor = uiColor;
    highlightColor = hlColor;
    [self drawBackground];
    [self drawHighlight];
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
