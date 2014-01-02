//
//  JSONHelper.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 10/19/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#define X_GRAVITLY_CLIENT_ID @"51xTw0GmAy"
#define X_GRAVITLY_REST_API_KEY @"a58c9ce7dca9c9e6536187bc7fa48bec"

#import "JSONHelper.h"
#import <AFHTTPClient.h>
#import <AFJSONRequestOperation.h>

@implementation JSONHelper

@synthesize delegate;

- (void)requestJSON:(NSDictionary *)params withBaseURL:(NSString *)baseUrl withEndPoint:(NSString *)endPoint {
 

    NSURL *url = [NSURL URLWithString:baseUrl];
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:url];
    
    [client clearAuthorizationHeader];
    [client setDefaultHeader:@"X-Gravitly-Client-Id" value:X_GRAVITLY_CLIENT_ID];
    [client setDefaultHeader:@"X-Gravitly-REST-API-Key" value:X_GRAVITLY_REST_API_KEY];
    
    [client getPath:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id json) {
        NSError *error = nil;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:&error];
        NSLog(@">>>>>> HAS JSON %@", jsonDictionary);
        [delegate performSelector:@selector(didReceiveJSONResponse:) withObject:jsonDictionary];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@">>>>>> JSON ERROR %@", error.localizedDescription);
        [delegate performSelector:@selector(didNotReceiveJSONResponse:) withObject:error];
    }];
    
}

@end


