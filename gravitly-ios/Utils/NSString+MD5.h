//
//  NSString+MD5.h
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/11/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (MD5)

-(NSString *)md5Value;

@end
