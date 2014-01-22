//
//  GVPointAnnotation.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 1/22/14.
//  Copyright (c) 2014 Geric Encarnacion. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Feed.h"

@interface GVPointAnnotation : MKPointAnnotation

@property (strong, nonatomic) Feed *feed;

@end
