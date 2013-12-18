//
//  GVFlickr.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVFlickr.h"
#import "GVCommons.h"
#import "NSString+MD5.h"
#import <AFNetworking.h>
#import <Parse/Parse.h>

@implementation GVFlickr

@synthesize flickrAuthToken;

- (void)loginToFlickr
{
    NSString *perms = @"write";
    NSString *apiSig = [NSString stringWithFormat:@"%@api_key%@perms%@", FLICKR_CLIENT_SECRET, FLICKR_CLIENT_KEY, perms].md5Value;
    
    NSString *urlString = [NSString stringWithFormat:@"http://flickr.com/services/auth/?api_key=%@&perms=%@&api_sig=%@", FLICKR_CLIENT_KEY, perms, apiSig];
    
    NSLog(@"STEP 3: %@", urlString);
    
    NSURL *loginURL = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] openURL:loginURL];
}

- (void)getAuthTokenWithFrob:(NSString *)frob
{
    NSString *method = @"flickr.auth.getToken";
    NSString *format = @"json";
    NSString *nojsoncallback = @"1";
    NSString *apiSig = [NSString stringWithFormat:@"%@api_key%@format%@frob%@method%@nojsoncallback%@", FLICKR_CLIENT_SECRET, FLICKR_CLIENT_KEY, format, frob, method, nojsoncallback].md5Value;
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=%@&api_key=%@&frob=%@&format=json&nojsoncallback=1&api_sig=%@", method, FLICKR_CLIENT_KEY, frob,apiSig];
    
    NSLog(@"STEP 5: %@", urlString);
    
    NSURL *authTokenURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:authTokenURL];
    [request setHTTPMethod:@"GET"];
    
    NSError *error = nil;
    NSURLResponse *response =[[NSURLResponse alloc]init];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *JSON = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] valueForKey:@"auth"];
    NSString *authToken = [[JSON valueForKey:@"token"] valueForKey:@"_content"];
    NSDictionary *userCredentials = [JSON valueForKey:@"user"];
    
    if (authToken) {
        [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"FLICKR_AUTH_TOKEN"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self setFlickrAuthToken:authToken];
        [[PFUser currentUser] setObject:authToken forKey:@"flickrAuthToken"];
        [[PFUser currentUser] save];
    }

    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //[connection start];
}

-(void)uploadToFlickr:(NSDictionary *)dictionary;
{
    [[PFUser currentUser] refresh];
    NSString *authToken = (NSString *)[[PFUser currentUser] objectForKey:@"flickrAuthToken"];
    
    NSLog(@"AUTH TOKEN %@", authToken);
    
    if (authToken.length > 1) {
        NSData *imageData = (NSData *)[dictionary objectForKey:@"imageData"];
        NSString *description = (NSString *)[dictionary objectForKey:@"caption"];
        NSString *isPublic = (NSString *)[dictionary objectForKey:@"isPublic"];
        
        NSString *apiSig = [NSString stringWithFormat:@"%@api_key%@auth_token%@description%@is_public%@", FLICKR_CLIENT_SECRET, FLICKR_CLIENT_KEY, authToken, description, isPublic].md5Value;
        
        NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/"];
        NSURL *uploadPhotoURL = [NSURL URLWithString:urlString];
        
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:uploadPhotoURL];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       FLICKR_CLIENT_KEY, @"api_key",
                                       authToken, @"auth_token",
                                       apiSig, @"api_sig",
                                       description, @"description",
                                       isPublic, @"is_public",
                                       nil];
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"services/upload/" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"photo" fileName:@"Gravitly" mimeType:@"image/jpeg"];
        }];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject) {
                NSLog(@"FLICKRRRRR!");
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if([operation.response statusCode] == 403)
            {
                NSLog(@"Upload Failed");
                return;
            }
            if (error) {
                NSLog(@"Error %@", error);
                [NSThread sleepForTimeInterval:1];
            }
        }];
        
        [operation start];
    }
}

+ (BOOL)isLinkedWithUser:(PFUser *)user
{
    BOOL isLinked = NO;
    if ([[user objectForKey:@"flickrAuthToken"] length] > 0) {
        isLinked = YES;
    }    
    return isLinked;
}

+ (void)unlinkUser:(PFUser *)user
{
    [user removeObjectForKey:@"flickrAuthToken"];
    [user save];
    [user refresh];
}

@end
