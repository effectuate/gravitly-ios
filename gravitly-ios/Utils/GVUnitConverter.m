//
//  GVUnitConverter.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 12/19/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVUnitConverter.h"

@implementation GVUnitConverter

+(NSDictionary *)getCounterpartUnit
{
    NSDictionary *dict = @{@"ft": @"m",
                           @"m": @"ft",
                           @"F": @"C",
                           @"C": @"F",
                           @"mph": @"kph",
                           @"kph": @"mph",
                           @"in": @"cm",
                           @"cm": @"in",
                           @"ft": @"m",
                           @"m": @"ft",
                           };
    return dict;
}


@end
