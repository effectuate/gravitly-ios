//
//  GVAFHTTPManager.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/19/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVAFHTTPManager.h"
#import <AFJSONRequestOperation.h>
#import <AFNetworkActivityIndicatorManager.h>

@implementation GVAFHTTPManager


- (void)setUsername:(NSString *)username andPassword:(NSString *)password
{
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:username password:password];
}


- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if(!self)
        return nil;
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return self;
}

+ (GVAFHTTPManager *)sharedManager
{
    static dispatch_once_t pred;
    static GVAFHTTPManager *_sharedManager = nil;
    
    dispatch_once(&pred, ^{ _sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://webapi.webnuggets.cloudbees.net"]]; });
    return _sharedManager;
}

@end
