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
    }
    
    //miles per hour to km per hour
    if ([f isEqualToString:@"mph"] && [t isEqualToString:@"kph"]) {
        float a = self.floatValue * 0.621371;
        NSLog(@"wewewew %f", self.floatValue);
        
        converted = [NSNumber numberWithFloat:a];
    }
    

    NSLog(@">>>>>>>>> from %@  to %@ converted %f", f, t, converted.floatValue);
    return converted;
}

@end
