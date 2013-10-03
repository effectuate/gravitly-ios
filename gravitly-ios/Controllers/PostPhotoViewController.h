//
//  PostPhotoViewController.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/10/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVBaseViewController.h"
#import "SNSHelperDelegate.h"

@interface PostPhotoViewController : GVBaseViewController<UITextViewDelegate> {
    id <SNSHelperDelegate> snsDelegate;
}

@property (nonatomic, strong) UIImage *imageHolder;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet GVTextView *captionTextView;
@property (strong, nonatomic) IBOutlet UIView *smaView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain) id snsDelegate;

//TODO:Delete
@property (strong, nonatomic) IBOutlet GVButton *activityButton;
@property (strong, nonatomic) IBOutlet GVButton *enhancementsButton;

- (IBAction)addActivity:(id)sender;
- (IBAction)addEnhancement:(id)sender;

@end
