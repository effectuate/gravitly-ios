//
//  PhotoFeedCell.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/26/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "PhotoFeedCell.h"

@implementation PhotoFeedCell

@synthesize hashTagsView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)prepareForReuse
{
//    NSLog(@">>>>>>>>> reuse");
    [[hashTagsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
