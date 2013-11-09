//
//  GVImageView.m
//  gravitly-ios
//
//  Created by Eli Dela Cruz on 11/9/13.
//  Copyright (c) 2013 Geric Encarnacion. All rights reserved.
//

#import "GVImageView.h"
#import "AppDelegate.h"

@implementation GVImageView

@synthesize urlString = _urlString;
@synthesize operation = _operation;
@synthesize cachedImages;
@synthesize imageFilename;

- (NSString *)urlString
{
    if (!_urlString) {
        _urlString = @"";
    }
    return _urlString;
}

- (id)initWithFrame:(CGRect)frame urlString:(NSString *)urlString tag:(NSUInteger)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.urlString = urlString;
        // image is grey tile before loading
        self.backgroundColor = [UIColor grayColor];
        // set the tag so we can find this image on the UI if we need to
        self.tag = tag;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame urlString:@"" tag:0];
}

-(void)getImageFromNetwork:(NSOperationQueue *)queue {
    
    //Add operation to queue
    self.operation = [[GetImageOperation alloc] init];
    [self.operation setUrlString:self.urlString];
    
    //Add listener for the reply
    [self.operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:nil];
    [queue addOperation:self.operation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)operation change:(NSDictionary *)change context:(void *)context {
    
    NSData *data = [self.cachedImages objectForKey:self.imageFilename] ? [self.cachedImages objectForKey:self.imageFilename] : nil;
    
    // Check if there's the same image in the cache
    if (data) {
        NSLog(@"meron na >>> %@", self.imageFilename);
        
        self.image=[UIImage imageWithData:[self.operation data]];
        self.operation = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ly.gravit.downloadingImages" object:nil];
    } else {
        
        // when the image is finished loading, respond by loading the data into this class's image object, so that
        // it appears on the ScrollView.
        
        if ([operation isEqual:self.operation]) {
            [self.operation removeObserver:self forKeyPath:@"isFinished"];
            if ([self.operation imageWasFound]) {
                self.image=[UIImage imageWithData:[self.operation data]];
            }
            else {
                self.image=[UIImage imageNamed:@"placeholder.png"];
            }
            // notify that we are done with this image back to the ViewController
            self.operation = nil; // this line is important!
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ly.gravit.downloadingImages" object:nil];
        }
    }
}

- (void) dealloc {
    
    @try{
        [self.operation removeObserver:self forKeyPath:@"isFinished" context:NULL];
    }@catch(id anException){
        //do nothing. If we can't remove the observer then there was no attachment.
    }
    self.urlString = nil;
    self.operation = nil;
    
}

@end
