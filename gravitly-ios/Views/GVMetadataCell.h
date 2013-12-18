//
//  GVMetadataCell.h
//  gravitly-ios
//
//  Created by Geric Encarnacion on 10/20/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVActivityField.h"
#import "GVTextField.h"

@interface GVMetadataCell : UITableViewCell

@property (strong, nonatomic) GVActivityField *activityField;
@property (strong, nonatomic) IBOutlet GVTextField *metadataTextfield;

@end
