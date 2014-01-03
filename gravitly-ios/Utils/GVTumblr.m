//
//  GVTumblr.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 1/2/14.
//  Copyright (c) 2014 Geric Encarnacion. All rights reserved.
//

#import "GVTumblr.h"
#import "AppDelegate.h"
#import "GVCommons.h"
#import <TMAPIClient.h>

@implementation GVTumblr

-(void)connectTumblr
{
    [TMAPIClient sharedInstance].OAuthConsumerKey = TUMBLR_CLIENT_KEY;
    [TMAPIClient sharedInstance].OAuthConsumerSecret = TUMBLR_CLIENT_SECRET;
    
    [[TMAPIClient sharedInstance] authenticate:@"gravitly:" callback:^(NSError *error) {
        NSLog(@"ERROR %@", error.debugDescription);
        NSLog(@">>>>>>>> heueheueh %@", [[TMAPIClient sharedInstance] OAuthToken]);
    }];
    
    /*AFOAuth1Client *tumblrClient = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.tumblr.com/"]
                                                                        key:TUMBLR_CLIENT_KEY
                                                                     secret:TUMBLR_CLIENT_SECRET];
    [tumblrClient authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token"
                                    userAuthorizationPath:@"/oauth/authorize"
                                              callbackURL:[NSURL URLWithString:@"gravitly://authTumblr"]
                                          accessTokenPath:@"/oauth/access_token"
                                             accessMethod:@"POST"
                                                    scope:nil
                                                  success:^(AFOAuth1Token *aToken, id responseObject) {
                                                      NSLog(@">>>>>>>>> ACCESS TOKEN %@", aToken);
                                                  }
                                                  failure:^(NSError *error) {
                                                      NSLog(@">>>>>>>>> ERRORORORORO %@", error.description);
                                                  }];*/
    

    
    /*consumer = [[OAConsumer alloc] initWithKey:TUMBLR_CLIENT_KEY secret:TUMBLR_CLIENT_SECRET];
    NSURL* requestTokenUrl = [NSURL URLWithString:@"http://www.tumblr.com/oauth/request_token"];

    OAMutableURLRequest *requestTokenRequest = [[OAMutableURLRequest alloc] initWithURL:requestTokenUrl
                                                                                consumer:consumer
                                                                                   token:nil
                                                                                   realm:nil
                                                                       signatureProvider:nil];
    
    OARequestParameter *callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:@"gravitly://authTumblr"] ;
    [requestTokenRequest setHTTPMethod:@"POST"];
    [requestTokenRequest setParameters:[NSArray arrayWithObject:callbackParam]];
    
    
    OADataFetcher *dataFetcher = [[OADataFetcher alloc] init];
    [dataFetcher fetchDataWithRequest:requestTokenRequest
                             delegate:self
                    didFinishSelector:@selector(didReceiveRequestToken:data:)
                      didFailSelector:@selector(didFailOAuth:error:)];*/
    
}
//
//- (void)didReceiveRequestToken:(OAServiceTicket *)ticket data:(NSData *)data
//{
//    
//    NSString *httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    requestToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
//    
//    NSURL *authorizeUrl = [NSURL URLWithString:@"https://www.tumblr.com/oauth/authorize"];
//    OAMutableURLRequest* authorizeRequest = [[OAMutableURLRequest alloc] initWithURL:authorizeUrl
//                                                                             consumer:nil
//                                                                                token:nil
//                                                                                realm:nil
//                                                                    signatureProvider:nil];
//    
//    NSString *oauthToken = requestToken.key;
//    
//    OARequestParameter* oauthTokenParam = [[OARequestParameter alloc] initWithName:@"oauth_token" value:oauthToken];
//    [authorizeRequest setParameters:[NSArray arrayWithObject:oauthTokenParam]];
//    
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    webView.scalesPageToFit = YES;
//    
//    [[[UIApplication sharedApplication] keyWindow] addSubview:webView];
//    webView.delegate = self;
//    [webView loadRequest:authorizeRequest];
//    
//}
//
//- (void)didReceiveAccessToken:(OAServiceTicket *)ticket data:(NSData *)data
//{
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    accessToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
//    NSString *OAuthKey = accessToken.key;    // ACCESS TOKEN
//    NSString *OAuthSecret = accessToken.secret;  // SECRET TOKEN
//}
//
//- (void)didFailOAuth:(OAServiceTicket*)ticket error:(NSError*)error
//{
//    // ERROR!
//}
//
//#pragma mark UIWebViewDelegate
//
//- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
//    
//    if ([[[request URL] scheme] isEqualToString:@"gravitly://authTumblr"]) {
//        
//        // Extract oauth_verifier from URL query
//        
//        NSString* verifier = nil;
//        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
//        
//        for (NSString* param in urlParams) {
//            NSArray* keyValue = [param componentsSeparatedByString:@"="];
//            NSString* key = [keyValue objectAtIndex:0];
//            if ([key isEqualToString:@"oauth_verifier"]) {
//                verifier = [keyValue objectAtIndex:1];
//                break;
//            }
//        }
//        
//        if (verifier) {
//            NSURL* accessTokenUrl = [NSURL URLWithString:@"https://www.tumblr.com/oauth/access_token"];
//            OAMutableURLRequest* accessTokenRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenUrl
//                                                                                       consumer:consumer
//                                                                                          token:requestToken
//                                                                                          realm:nil
//                                                                              signatureProvider:nil];
//            
//            OARequestParameter *verifierParam = [[OARequestParameter alloc] initWithName:@"oauth_verifier" value:verifier];
//            [accessTokenRequest setHTTPMethod:@"POST"];
//            [accessTokenRequest setParameters:[NSArray arrayWithObject:verifierParam]];
//    
//            OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
//            [dataFetcher fetchDataWithRequest:accessTokenRequest
//                                     delegate:self
//                            didFinishSelector:@selector(didReceiveAccessToken:data:)
//                              didFailSelector:@selector(didFailOAuth:error:)];
//            
//        } else {
//            // ERROR!
//        }
//        
//        [webView removeFromSuperview];
//        return NO;
//        
//    }
//    return YES;
//    
//}
//
//- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
//    
//    // ERROR!
//    
//}

@end
