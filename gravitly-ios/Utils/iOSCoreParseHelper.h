//
//  iOSCore.h
//  Cardinal-Iph
//
//  Created by Rai Orofino on 3/26/13.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "LogInViewController.h"

typedef void (^ResultBlock)(NSArray* objects, NSError* error);
typedef void (^ObjectResultBlock)(PFObject* objects, NSError* error);

@interface iOSCoreParseHelper : NSObject

+ (void)findAll:(NSString*)className :(ResultBlock)handler;
+ (void)findAllInBackground:(NSString*)className :(ResultBlock)handler;
+ (void)find:(NSString*)className whereKey:(NSString*)whereKey equalTo:(NSString *)equalTo :(ResultBlock)handler;
+ (void)findInBackground:(NSString*)className whereKey:(NSString*)whereKey equalTo:(NSString *)equalTo :(ResultBlock)handler;
+ (void)getFirstObjectInBackground:(NSString*)className whereKey:(NSString*)whereKey equalTo:(NSString *)equalTo :(ObjectResultBlock)handler;
+ (void)getContainedObject:(NSString *)className whereKey:(NSString *)whereKey containedIn:(NSArray *)containedIn :(ResultBlock)handler;
+ (void)getPointerSubClass:(NSString *)className subClass:(NSString *)subClass whereKey:(NSString *)whereKey objectId:(NSString *)objectId :(ResultBlock)handler;
+ (void)deleteObject:(NSString *)className objectId:(NSString *)objectId :(void(^)(int *result))handler;
+ (void)launchParseLogin:(UIViewController *)uiViewController;
+ (void)isAuthenticated:(UIViewController *)viewController;

@end
