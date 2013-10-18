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
@property NSString *latitude;
@property NSString *longitude;
@property NSString *latitudeRef;
@property NSString *longitudeRef;
@property NSString *altitude;
@property NSString *windDirection;
@property NSString *location1; //name
@property NSString *location2; //locality
@property Activity *activity;
@property NSString *swellHeightM;
@property NSString *swellPeriodSecs;
@property NSString *period;
@property NSString *waterTempC;
@property NSString *waterTempF;
@property NSString *country;
@property NSString *cloudcover;
@property NSString *humidity;
@property NSString *precipMM;
@property NSString *pressure;
@property NSString *sigHeightM;
@property NSString *swellDir;
@property NSString *visibility;
@property NSString *weatherCode;
@property NSString *windDir16Point;
@property NSString *windDirDegree;
@property NSString *windSpeedKmph;
@property NSString *windSpeedMiles;



@end
