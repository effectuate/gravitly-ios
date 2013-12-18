//
//  GVFlickr.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef void (^SucceedBlock)(BOOL succeed, NSError *error);

@interface GVFlickr : NSObject

- (void)loginToFlickr;
- (void)getAuthTokenWithFrob:(NSString *)frob;
- (void)uploadToFlickr:(NSDictionary *)dictionary;
- (void)uploadToFlickr:(NSDictionary *)dictionary withBlock:(SucceedBlock)block;
+ (BOOL)isLinkedWithUser:(PFUser *)user;
+ (void)unlinkUser:(PFUser *)user;

@end
