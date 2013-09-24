//
//  GVHTTPClient.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVHTTPClient.h"
#import <AFHTTPClient.h>
#import <AFJSONRequestOperation.h>
#import <AFNetworkActivityIndicatorManager.h>

@implementation GVHTTPClient

-(id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    self.parameterEncoding = AFJSONParameterEncoding;
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return self;
    
}

+(GVHTTPClient *)sharedClient {
    static GVHTTPClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://webapi.webnuggets.cloudbees.net"]];
    });
    return _sharedClient;
}

@end
