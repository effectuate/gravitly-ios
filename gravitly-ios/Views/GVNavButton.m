//
//  GVNavButton.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/19/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVNavButton.h"

@implementation GVNavButton {
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
        [self setButtonColor:[UIColor redColor]];
        //[self setButtonColor:[GVColor navigationBarColor]];
    }
    return self;
}

- (void)drawBackground
{
    if (!_backgroundLayer)
    {
        _backgroundLayer = [CALayer layer];
        _backgroundLayer.backgroundColor = backgroundColor.CGColor;
        
        [self.layer insertSublayer:_backgroundLayer atIndex:0];
    } else {
        _backgroundLayer = [self.layer.sublayers objectAtIndex:0];
        _backgroundLayer.backgroundColor = backgroundColor.CGColor;
    }
}

- (void)drawHighlight
{
    if (!_highlightLayer)
    {
        _highlightLayer = [CALayer layer];
        _highlightLayer.backgroundColor = highlightColor.CGColor;
        [self.layer insertSublayer:_highlightLayer atIndex:1];
    } else {
        _highlightLayer = [self.layer.sublayers objectAtIndex:1];
        _highlightLayer.backgroundColor = highlightColor.CGColor;
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
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    _highlightLayer.hidden = !highlighted;
    
    [CATransaction commit];
}

-(void)setButtonColor:(UIColor *)color {
    
    UIColor *uiColor = [[UIColor alloc] init];
    UIColor *hlColor = [[UIColor alloc] init];
    
    uiColor = color;
    hlColor = uiColor;
        
    backgroundColor = uiColor;
    highlightColor = hlColor;
    [self drawBackground];
    [self drawHighlight];
}

@end
