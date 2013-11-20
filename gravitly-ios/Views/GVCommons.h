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

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)

#define URL_IMAGE @"http://s3.amazonaws.com/gravitly.uploads.dev/%@"
#define X_GRAVITLY_CLIENT_ID @"51xTw0GmAy"
#define X_GRAVITLY_REST_API_KEY @"a58c9ce7dca9c9e6536187bc7fa48bec"

#define kClientId @"959982256070.apps.googleusercontent.com"

#define kgvFontSize 20.0f
#define kgvFontSize18 18.0f
#define kgvFontSize16 16.0f
#define kgvFontSize14 14.0f
#define kgvFontSize12 12.0f

//Flickr
#define kStoredAuthTokenKeyName @"FlickrOAuthToken"
#define kStoredAuthTokenSecretKeyName @"FlickrOAuthTokenSecret"
#define kGetAccessTokenStep @"kGetAccessTokenStep"
#define kCheckTokenStep @"kCheckTokenStep"

#define FLICKR_CLIENT_KEY @"d08f4cd995f901e6ea2ae783f3e82486"
#define FLICKR_CLIENT_SECRET @"1b84db1a593d1c97"

//NSString *SRCallbackURLBaseString = @"snapnrun://auth"

#import "GVColor.h"
#import "GVLabel.h"
#import "GVButton.h"
#import "GVNavButton.h"
#import "GVTextField.h"
#import "GVTextView.h"
#import <MBProgressHUD.h>

#endif
