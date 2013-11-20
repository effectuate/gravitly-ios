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

@implementation GVFlickr

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
    
    NSLog(@"\n \n \n authToken %@ \n \n \n userCredentials %@", authToken, userCredentials);
    
    [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"FLICKR_AUTH_TOKEN"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //[connection start];
}

-(void)uploadToFlickr:(NSData *)imageData;
{
    //NSData *photo = [photoDetails objectForKey:@"photo"];
    NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"FLICKR_AUTH_TOKEN"];
    
    if (authToken.length) {
        NSString *apiSig = [NSString stringWithFormat:@"%@api_key%@auth_token%@", FLICKR_CLIENT_SECRET, FLICKR_CLIENT_KEY, authToken].md5Value;
        
        //NSString *urlString = [NSString stringWithFormat:@"http://up.flickr.com/services/upload/?photo=%@&api_sig=%@", photo, apiSig];
        
        
        NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/"];
        NSURL *uploadPhotoURL = [NSURL URLWithString:urlString];
        /*NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:uploadPhotoURL];
         [request setURL:uploadPhotoURL];
         [request setHTTPMethod:@"POST"];*/
        
        
        /*NSString *boundary = @"---------------------------7d44e178b0434";
         
         [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
         
         NSMutableData *body = [NSMutableData data];
         [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
         
         [body appendData:[@"Content-Disposition: form-data; name=\"api_key\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:[[NSString stringWithFormat:@"%@\r\n", FLICKR_CLIENT_KEY] dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
         
         [body appendData:[@"Content-Disposition: form-data; name=\"auth_token\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:[[NSString stringWithFormat:@"%@\r\n", authToken] dataUsingEncoding:NSUTF8StringEncoding]];
         
         [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:[@"Content-Disposition: form-data; name=\"api_sig\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:[[NSString stringWithFormat:@"%@\r\n", apiSig] dataUsingEncoding:NSUTF8StringEncoding]];
         
         [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:[@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
         
         [body appendData:imageData];
         [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
         [request setHTTPBody:body];*/
        
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:uploadPhotoURL];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       FLICKR_CLIENT_KEY, @"api_key",
                                       authToken, @"auth_token",
                                       apiSig, @"api_sig",
                                       nil];
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"services/upload/" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"photo" fileName:@"filename" mimeType:@"image/jpeg"];
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

@end
