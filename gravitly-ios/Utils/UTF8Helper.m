//
//  UTF8Helper.m
//  OnTheSpot
//
//  Created by Eli Dela Cruz on 5/27/13.
//  Copyright (c) 2013 DYNOBJX. All rights reserved.
//

#import "UTF8Helper.h"

@implementation UTF8Helper

- (NSString *)convertStringToUTF8Encoding:(NSString *)text WithFormat:(NSString *)format{
    NSString *bodyString = [NSString stringWithFormat:@"%@%@", format, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    bodyString = [bodyString stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];
    bodyString = [bodyString stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
    return bodyString;
}

@end
