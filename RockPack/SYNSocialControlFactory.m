//
//  SYNButtonControlFactory.m
//  dolly
//
//  Created by Michael Michailidis on 28/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialControlFactory.h"
#import "SYNSocialAddControl.h"
#import "SYNSocialLikeControl.h"

@implementation SYNSocialControlFactory


+ (instancetype) defaultFactory
{
    static dispatch_once_t onceQueue;
    static SYNSocialControlFactory *factory = nil;
    
    dispatch_once(&onceQueue, ^{
        factory = [[self alloc] init];
    });
    return factory;
}

-(SYNSocialControl*)createControlForType:(SocialControlType)type forTitle:(NSString*)title andPosition:(CGPoint)position
{
    
    SYNSocialControl* sControl;
    
    switch (type)
    {
        case SocialControlTypeDefault:
            sControl = [SYNSocialControl buttonControl];
            break;
            
        case SocialControlTypeLike:
            sControl = [SYNSocialLikeControl buttonControl];
            break;
            
        case SocialControlTypeAdd:
            sControl = [SYNSocialAddControl buttonControl];
            break;
    }
    
    
    
    if(title && (type != SocialControlTypeAdd)) // the add button has not text
    {
        sControl.title = title;
    }
    
    sControl.center = position;
    sControl.frame = CGRectIntegral(sControl.frame); // frame for pixelation
    
    return sControl;
}

@end
