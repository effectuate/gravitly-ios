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

-(NSDictionary *)rawFieldsFor:(NSString *)activity
{
    return [activityMap valueForKey:activity];
}

-(NSArray *)fieldsFor:(NSString *)activity
{
    NSDictionary *fields = [self rawFieldsFor:activity];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *metadata = [fields valueForKey:@"fields"];
    
    for(NSDictionary *dict in metadata) {
        GVActivityField *af = [[GVActivityField alloc] init];
        af.name = [dict valueForKey:@"name"];
        af.tagFormat = [dict valueForKey:@"tagFormat"];
        id editable = [dict valueForKey:@"userEditable"];
        if (editable) {
            af.editable = [editable integerValue];
        }
        [array addObject:af];
    }
    return array;
}

@end
