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
    // encode tweet
    UTF8Helper *helper = [[UTF8Helper alloc] init];
    NSString *bodyString = [helper convertStringToUTF8Encoding:text WithFormat:@"status="];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"/*@"https://api.twitter.com/1.1/statuses/update.json"*/];
    
    NSString *stringBoundary = @"---------------------------14737809831466499882746641449";
    
    //set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary];    
    
    //post body
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"status\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //attach image
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"media[]\"; filename=\"image.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    NSLog(@"%@ ", body);
    
    
    NSMutableURLRequest *tweetRequest = [NSMutableURLRequest requestWithURL:url];
    tweetRequest.HTTPMethod = @"POST";
    tweetRequest.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [[PFTwitterUtils twitter] signRequest:tweetRequest];
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    // Post status synchronously.
    [NSURLConnection sendSynchronousRequest:tweetRequest returningResponse:&response error:&error];
    block(!error, error);
}

@end
