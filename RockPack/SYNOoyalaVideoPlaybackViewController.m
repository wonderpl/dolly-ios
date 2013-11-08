//
//  SYNOoyalaVideoPlaybackViewController.m
//  dolly
//
//  Created by Nick Banks on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOoyalaVideoPlaybackViewController.h"

@interface SYNOoyalaVideoPlaybackViewController ()

@end

@implementation SYNOoyalaVideoPlaybackViewController

static UIWebView* ooyalaVideoWebViewInstance;

+ (instancetype) sharedInstance
{
    static SYNOoyalaVideoPlaybackViewController *_sharedInstance = nil;
    
    if (!_sharedInstance)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            // Create our shared intance
            _sharedInstance = [[self allocWithZone: nil] init];
            // Create the static instances of our webviews
//            ooyalaVideoWebViewInstance = [SYNOoyalaVideoPlaybackViewController createNewOOyalaView];
        });
    }
    
    return _sharedInstance;
}

@end
