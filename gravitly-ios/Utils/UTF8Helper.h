//
//  UTF8Helper.h
//  OnTheSpot
//
//  Created by Eli Dela Cruz on 5/27/13.
//  Copyright (c) 2013 DYNOBJX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UTF8Helper : NSObject

- (NSString *)convertStringToUTF8Encoding:(NSString *)text WithFormat:(NSString *)format;

@end

