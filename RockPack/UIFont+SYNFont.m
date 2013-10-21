//
//  UIFont+SYNFont.m
//  RockPack
//
//  Created by Nick Banks on 15/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "UIFont+SYNFont.h"

@implementation UIFont (SYNFont)

+ (UIFont *) lightCustomFontOfSize: (CGFloat) fontSize
{
    return [UIFont fontWithName: @"ProximaNova-Light"
                           size: fontSize];
}


+ (UIFont *) regularCustomFontOfSize: (CGFloat) fontSize
{
    return [UIFont fontWithName: @"ProximaNova-Regular"
                           size: fontSize];
}


@end
