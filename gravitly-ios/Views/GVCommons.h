//
//  GVCommons.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#ifndef gravitly_ios_GVCommons_h
#define gravitly_ios_GVCommons_h

#define formatLongitude(long)    ( (M_PI * (long)) / 180.0 )
#define formatLatitude(lat)      ( (M_PI * (lat)) / 180.0 )

#define kgvRobotoCondensedRegular @"RobotoCondensed-Regular"
#define kgvRobotoCondensedBold @"RobotoCondensed-Bold"
#define kgvRobotoCondensedItalic @"RobotoCondensed-Light"

#define CGRectSetWidth(r, w)    CGRectMake(r.origin.x, r.origin.y, w, r.size.height)
#define CGRectSetHeight(r, h)    CGRectMake(r.origin.x, r.origin.y, r.size.width, h)
#define CGRectSetX(r, x)    CGRectMake(x, r.origin.y, r.size.width, r.size.height)
#define CGRectSetY(r, y)    CGRectMake(r.origin.x, y, r.size.width, r.size.height)

#define ViewSetWidth(view, w)   view.frame = CGRectSetWidth(view.frame, w)


#define kgvFontSize 20.0f
#define kgvFontSize18 18.0f
#define kgvFontSize16 16.0f
#define kgvFontSize14 14.0f
#define kgvFontSize12 12.0f

#import "GVColor.h"
#import "GVLabel.h"
#import "GVButton.h"
#import "GVNavButton.h"
#import "GVTextField.h"
#import "GVTextView.h"
#import <MBProgressHUD.h>

#endif
