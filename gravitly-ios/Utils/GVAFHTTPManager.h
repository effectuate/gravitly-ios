//
//  GVAFHTTPManager.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/19/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "AFHTTPClient.h"

@interface GVAFHTTPManager : AFHTTPClient

- (void)setUsername:(NSString *)username andPassword:(NSString *)password;

+ (GVAFHTTPManager *)sharedManager;

@end
