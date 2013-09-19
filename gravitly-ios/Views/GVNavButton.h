//
//  GVNavButton.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/19/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVCommons.h"
#import "GVColor.h"

@interface GVNavButton : UIButton

@property (strong,nonatomic) CALayer *backgroundLayer;
@property (strong,nonatomic) CALayer *highlightLayer;

 
-(void)setButtonColor:(UIColor *)color;

@end
