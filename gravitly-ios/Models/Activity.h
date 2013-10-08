//
//  Activity.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 10/8/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSCoreParseHelper.h"

@interface Activity : NSObject

@property NSString *objectId;
@property NSString *name;
@property NSString *tagName;

+ (void)findAll: (ResultBlock )block;
+ (void)findAllInBackground: (ResultBlock )block;

@end
