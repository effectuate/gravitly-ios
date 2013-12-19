//
//  GVWebHelper.h
//  gravitly-ios
//
//  Created by Giancarlo Inductivo on 10/18/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GVWebHelper : NSObject

-(NSArray *)activityNames;
-(NSDictionary *)rawFieldsForActivity:(NSString *)activity;
-(NSArray *)fieldsForActivity:(NSString *)activity;
-(NSDictionary *)metadataForActivity:(NSString *)activity fromJson:(NSData *)json;
-(NSString *)formatTag:(NSString *)string toPattern:(NSString *)pattern;

+(BOOL)isMetricUnit:(NSString *)unit;
+(NSString *)counterpartUnitOf:(NSString *)unit;
@end
