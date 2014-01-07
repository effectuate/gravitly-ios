//
//  NSNumber+GVUnitConverter.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 12/19/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "NSNumber+GVUnitConverter.h"

@implementation NSNumber (GVUnitConverter)

-(NSNumber *)convertFromUnit:(NSString *)f toUnit:(NSString *)t;
{
    NSNumber *converted = [[NSNumber alloc] init];
    float a;
    
    if ([f isEqualToString:@"m"] && [t isEqualToString:@"ft"]) { //meter to feet
        a = self.floatValue * 3.28084;
        converted = [NSNumber numberWithFloat:a];
    } else if ([f isEqualToString:@"mph"] && [t isEqualToString:@"kph"]) { //miles per hour to km per hour
        a = self.floatValue * 1.60934;
        converted = [NSNumber numberWithFloat:a];
    } else if ([f isEqualToString:@"mi"] && [t isEqualToString:@"km"]) { //mi to km 2
        a = self.floatValue * 1.60934;
        converted = [NSNumber numberWithFloat:a];
    } else if ([f isEqualToString:@"km"] && [t isEqualToString:@"mi"]) { //mi to km 2
        a = self.floatValue * 0.621371;
        converted = [NSNumber numberWithFloat:a];
    } else if ([f isEqualToString:@"in"] && [t isEqualToString:@"cm"]) { //cm to inch
        a = self.floatValue * 2.54;
        converted = [NSNumber numberWithFloat:a];
    } else if ([f isEqualToString:@"cfs"] && [t isEqualToString:@"m3/s"]) { //cf to m3
        a = self.floatValue * 0.0283168;
        converted = [NSNumber numberWithFloat:a];
    } else if ([f isEqualToString:@"in"] && [t isEqualToString:@"mm"]) { //in to mm
        a = self.floatValue * 25.4;
        converted = [NSNumber numberWithFloat:a];
    } else if ([f isEqualToString:@"F"] && [t isEqualToString:@"C"]) { //F to C
        a = ((self.floatValue - 32.0f) * 5.0f) / 9.0f;
        converted = [NSNumber numberWithFloat:a];
    } else if ([f isEqualToString:@"C"] && [t isEqualToString:@"F"]) { //C to F
        a = ((self.floatValue * 9) / 5) + 32;
        converted = [NSNumber numberWithFloat:a];
    } else {
        NSLog(@"404 no conversion found");
    }
    return converted;
}


@end
