//
//  SNSHelper.h
//  OnTheSpot
//
//  Created by Giancarlo Inductivo on 4/25/13.
//  Copyright (c) 2013 DYNOBJX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SNSHelperDelegate.h"

@interface SNSHelper : NSObject<SNSHelperDelegate>

@property (strong, nonatomic) FBRequestConnection *fbRequestConnection;

-(void)fbShare:(NSString *)text block:(BooleanResultBlock)block;
-(void)tweet:(NSString *)text withImage:(UIImage *)image block:(BooleanResultBlock)block;

@end
