//
//  GVHTTPClient.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "AFHTTPClient.h"

@interface GVHTTPClient : AFHTTPClient

+(GVHTTPClient *)sharedClient;

@end
