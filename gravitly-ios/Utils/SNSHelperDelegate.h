//
//  SNSHelperDelegate.h
//  OnTheSpot
//
//  Created by Giancarlo Inductivo on 4/25/13.
//  Copyright (c) 2013 DYNOBJX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BooleanResultBlock)(BOOL succeeded, NSError *error);

@protocol SNSHelperDelegate <NSObject>

@required
-(void)fbShare:(NSString *)text block:(BooleanResultBlock)block;
//-(void)tweet:(NSString *)text withImage:(UIImage *)image block:(BooleanResultBlock)block;

@end
