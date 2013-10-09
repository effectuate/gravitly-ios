//
//  Metadata.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/8/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Activity.h"

@interface Metadata : NSObject

@property NSDate *dateCaptured;
@property float latitude;
@property float longitude;
@property double altitude;
@property float windDirection;
@property NSString *location1;
@property NSString *location2;
@property Activity *activity;
@property NSString *waveHeight;
@property NSString *period;
@property NSString *waterTempC;
@property NSString *waterTempF;

@end
