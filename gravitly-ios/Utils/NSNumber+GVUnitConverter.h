//
//  NSNumber+GVUnitConverter.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 12/19/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (GVUnitConverter)

-(NSNumber *)convertFromUnit:(NSString *)f toUnit:(NSString *)t;


@end
