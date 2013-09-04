//
//  CPLabel.h
//  CPScentControl
//
//  Created by Eli Dela Cruz on 7/30/13.
//  Copyright (c) 2013 DYNOBJX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVCommons.h"

typedef NS_OPTIONS(NSUInteger, GVLabelStyle) {
    GVRobotoCondensedRegularPaleGrayColor = 0,
    GVRobotoCondensedBoldPaleGrayColor
};

@interface GVLabel : UILabel

-(void)setLabelStyle: (GVLabelStyle)labelStyle size:(float)size;

@end
