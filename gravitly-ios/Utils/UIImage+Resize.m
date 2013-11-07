//
//  UIImage+Resize.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 9/26/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)resizeImageToSize:(CGSize)size {
    CGRect targetRect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(targetRect.size);
    [self drawInRect:targetRect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

@end
