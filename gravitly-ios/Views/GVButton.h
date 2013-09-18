//
//  CPButton.h
//  CPScentControl
//
//  Created by Eli Dela Cruz on 8/7/13.
//  Copyright (c) 2013 DYNOBJX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GVCommons.h"
#import "GVColor.h"

typedef NS_ENUM(NSUInteger, GVButtonColor) {
    GVButtonBlueColor = 0,
    GVButtonGrayColor,
    GVButtonDarkBlueColor
};

@interface GVButton : UIButton

@property (strong,nonatomic) CALayer *backgroundLayer;
@property (strong,nonatomic) CALayer *highlightLayer;

-(void)setButtonColor:(GVButtonColor)color;

@end
