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
    
    
    
    
    //meter to feet
    if ([f isEqualToString:@"m"] && [t isEqualToString:@"ft"]) {
        float a = self.floatValue * 3.28084;
        converted = [NSNumber numberWithFloat:a];
    } else if ([f isEqualToString:@"mph"] && [t isEqualToString:@"kph"]) { //miles per hour to kph
        float a = self.floatValue * 1.60934;
        converted = [NSNumber numberWithFloat:a];
    } else if ([f isEqualToString:@"mi"] && [t isEqualToString:@"km"]) { //mi to km
        float a = self.floatValue * 1.60934;
        converted = [NSNumber numberWithFloat:a];
    } else if ([f isEqualToString:@"in"] && [t isEqualToString:@"cm"]) { //in to cm
        float a = self.floatValue * 2.54;
        converted = [NSNumber numberWithFloat:a];
    }
    
    

    NSLog(@">>>>>>>>> from %@  to %@ converted %f", f, t, converted.floatValue);
    return converted;
}

@end
