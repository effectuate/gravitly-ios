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
@property NSString *latitudeRef;
@property NSString *longitudeRef;
@property double altitude;
@property float windDirection;
@property NSString *location1; //name
@property NSString *location2; //locality
@property Activity *activity;
@property float swellHeightM;
@property float swellPeriodSecs;
@property NSString *period;
@property NSString *waterTempC;
@property NSString *waterTempF;
@property NSString *country;
@property int cloudcover;
@property int humidity;
@property float precipMM;
@property int pressure;
@property float sigHeightM;
@property int swellDir;
@property int visibility;
@property int weatherCode;
@property NSString *windDir16Point;
@property int windDirDegree;
@property int windSpeedKmph;
@property int windSpeedMiles;



@end
