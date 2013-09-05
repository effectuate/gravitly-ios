//
//  SocialMediaAccountsController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/4/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVCommons.h"

@class SocialMediaAccountsController;

@protocol SocialMediaAccountsDelegate <NSObject>

@optional

-(void)socialMediaAccountsViewLabel:(NSString *)string;
-(void)socialMediaAccountsView:(SocialMediaAccountsController *)socialView;

@end

@interface SocialMediaAccountsController : UIView

@property (nonatomic, weak) id <SocialMediaAccountsDelegate> delegate;
@property (strong, nonatomic) IBOutlet GVLabel *label;


@end