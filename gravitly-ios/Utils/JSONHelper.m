//
//  JSONHelper.m
//  gravitly-ios
//
//  Created by Geric Encarnacion on 10/19/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "JSONHelper.h"
#import <AFHTTPClient.h>
#import <AFJSONRequestOperation.h>

@implementation JSONHelper

@synthesize delegate;

- (void)requestJSON:(NSDictionary *)params withBaseURL:(NSString *)baseUrl withEndPoint:(NSString *)endPoint {
 
    NSURL *url = [NSURL URLWithString:baseUrl];
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:url];
    
    [client getPath:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id json) {
        NSError *error = nil;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:&error];
        NSLog(@">>>>>> HAS JSON");
        [delegate performSelector:@selector(didReceiveJSONResponse:) withObject:jsonDictionary];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@">>>>>> JSON ERROR %@", error.localizedDescription);
        [delegate performSelector:@selector(didNotReceiveJSONResponse:) withObject:error];
    }];
    
}

@end


