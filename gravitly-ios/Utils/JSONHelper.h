//
//  JSONHelper.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 10/19/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSONHelper;

@protocol JSONHelper <NSObject>

@required

- (void)didReceiveJSONResponse:(NSDictionary *)json;
- (void)didNotReceiveJSONResponse: (NSError *)error;

@end

@interface JSONHelper : NSObject {
    id <JSONHelper> delegate;
}

@property (strong, nonatomic) id <JSONHelper> delegate;

- (void)requestJSON:(NSDictionary *)params withBaseURL:(NSString *)url withEndPoint:(NSString *)endPoint;

@end
