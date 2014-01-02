//
//  GVWebHelper.m
//  gravitly-ios
//
//  Created by Giancarlo Inductivo on 10/18/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVWebHelper.h"
#import "GVActivityField.h"

@implementation GVWebHelper

static NSData *mappingData;
static NSMutableDictionary *activityMap;

-(id)init
{
    NSString* dataFile = [[NSBundle mainBundle]pathForResource:@"mapping" ofType:@"json"];
    mappingData = [NSData dataWithContentsOfFile:dataFile];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:mappingData options:kNilOptions error:nil];
    NSDictionary *activities = [JSON valueForKey:@"activities"];
    activityMap = [[NSMutableDictionary alloc] init];
    
    for(NSDictionary *obj in activities) {
        [activityMap setObject:obj forKey:[obj objectForKey:@"name"]];
    }

    return self;
}

-(NSArray *)activityNames
{
    return [activityMap allKeys];
}

-(NSDictionary *)rawFieldsForActivity:(NSString *)activity
{
    return [activityMap valueForKey:activity];
}

-(NSArray *)fieldsForActivity:(NSString *)activity
{
    NSDictionary *fields = [self rawFieldsForActivity:activity];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *metadata = [fields valueForKey:@"fields"];
    
    for(NSDictionary *dict in metadata) {
        GVActivityField *af = [[GVActivityField alloc] init];
        af.name = [dict valueForKey:@"name"];
        af.displayName = [dict valueForKey:@"displayName"];
        af.tagFormat = [dict valueForKey:@"tagFormat"];
        id editable = [dict valueForKey:@"userEditable"];
        if (editable) {
            af.editable = [editable integerValue];
        }
        id unit = [dict valueForKey:@"unit"];
        if (unit) {
            af.unit = unit;
            af.subUnit = [dict valueForKey:@"subUnit"];
        }
        [array addObject:af];
    }
    return array;
}

-(NSDictionary *)metadataForActivity:(NSString *)activity fromJson:(NSData *)json {
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    NSArray *fields = [self fieldsForActivity:activity];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
    NSDictionary *activityEnv = [JSON valueForKey:activity];
    
    for(GVActivityField *field in fields) {
        id val = [activityEnv objectForKey:field.name];
        if (val) {
            [metadata setObject:[self formatTag:val toPattern:field.tagFormat] forKey:field.name];
        }
    }
    
    return metadata;
}

-(NSString *)formatTag:(NSString *)string toPattern:(NSString *)pattern {
    NSString *sansWhitespace = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [pattern stringByReplacingOccurrencesOfString:@"#x" withString:[NSString stringWithFormat:@"%@", sansWhitespace]];
}

+(BOOL)isMetricUnit:(NSString *)unit
{
    NSArray *metricUnits = @[@"m",@"kph",@"cm",@"m3/s",@"mmPPT",@"km"];
    return [metricUnits containsObject:unit];
}


@end
