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
-(NSDictionary *)rawFieldsFor:(NSString *)activity;
-(NSArray *)fieldsFor:(NSString *)activity;

@end
