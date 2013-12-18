//
//  GVFlickr.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface GVFlickr : NSObject

@property(nonatomic, strong) NSString *flickrAuthToken;

- (void)loginToFlickr;
- (void)getAuthTokenWithFrob:(NSString *)frob;
- (void)uploadToFlickr:(NSDictionary *)dictionary;
+ (BOOL)isLinkedWithUser:(PFUser *)user;
+ (void)unlinkUser:(PFUser *)user;

@end
