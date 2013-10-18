//
//  GVWebHelperTest.m
//  gravitly-ios
//
//  Created by Giancarlo Inductivo on 10/18/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "GVWebHelper.h"
#import "GVActivityField.h"

@interface GVWebHelperTest : GHTestCase

@end

@implementation GVWebHelperTest

-(void)testActivityNames
{
    GVWebHelper *helper = [[GVWebHelper alloc] init];
    NSArray *activityNames = [helper activityNames];
    GHTestLog([activityNames description]);
    GHAssertTrue(activityNames.count > 0, @"Activity Names must not be empty");
}

-(void)testRawFieldsForActivity
{
    GVWebHelper *helper = [[GVWebHelper alloc] init];
    NSDictionary *fields = [helper rawFieldsFor:@"Surf"];
    GHAssertTrue(fields.count > 0, @"Activity Fields must not be empty");
}

-(void)testFieldsForActivity
{
    GVWebHelper *helper = [[GVWebHelper alloc] init];
    NSArray *activityFields = [helper fieldsFor:@"Surf"];
    GHAssertTrue(activityFields.count > 0, @"Activity Fields must not be empty");
    
    for(GVActivityField *field in activityFields) {
        GHAssertTrue(field.name.length > 0 , @"Activity Name is required");
        GHTestLog(@"Field Name: %@ | tagFormat: %@ | userEditable: %d", field.name, field.tagFormat, field.editable);
    }
}

@end
