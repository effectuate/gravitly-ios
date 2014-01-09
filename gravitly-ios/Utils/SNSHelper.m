//
//  SNSHelper.m
//  OnTheSpot
//
//  Created by Giancarlo Inductivo on 4/25/13.
//  Copyright (c) 2013 DYNOBJX. All rights reserved.
//

#import "SNSHelper.h"
#import "Parse/Parse.h"
#import "UTF8Helper.h"

@implementation SNSHelper

-(void)fbShare:(NSString *)text block:(BooleanResultBlock)block {
    if (!FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES
            completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                if (error) {
                    block(!error, error);
                    return;
                }
        }];
    };
    
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    FBRequestHandler handler = ^(FBRequestConnection *connection, id result, NSError *error) {
        if (self.fbRequestConnection && connection != self.fbRequestConnection) {
            NSLog(@"not the completion we are looking for");
            return;
        }
        
        self.fbRequestConnection = nil;
        block(!error, error);
    };
    
    NSString *messageString=[NSString stringWithFormat:@"On The Spot: %@", text];
    FBRequest *request=[[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:@"me/feed" parameters:[NSDictionary dictionaryWithObject:messageString forKey:@"message"] HTTPMethod:@"POST"];
              [newConnection addRequest:request completionHandler:handler];
    [self.fbRequestConnection cancel];
    
    self.fbRequestConnection = newConnection;
    [newConnection start];
}

-(void)tweet:(NSString *)text withImage:(UIImage *)image block:(BooleanResultBlock)block {
    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.HTTPMethod = @"POST";
    NSString *stringBoundary = @"---------------------------33133---------------------------";
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"status\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", [text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"media[]\"; filename=\"image.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set URL
    [request setURL:requestURL];
    
    
    // Construct the parameters string. The value of "status" is percent-escaped.
    
    
    [[PFTwitterUtils twitter] signRequest:request];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    // Post status synchronously.
    NSData *data1 = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    
    // Handle response.
    if (!error) {
        NSString *responseBody = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        block(YES, error);
        //NSLog(@"Error: %@", responseBody);
    } else {
        block(YES, error);
    }
}

@end
