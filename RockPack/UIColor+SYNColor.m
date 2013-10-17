//
//  UIColor+SYNColor.m
//  RockPack
//
//  Created by Nick Banks on 15/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "UIColor+SYNColor.h"

@implementation UIColor (SYNColor)

+ (UIColor *) rockpacLedColor
{
    return [UIColor colorWithRed: 45.0f / 255.0f
                           green: 53.0f / 255.0f
                            blue: 58.0f / 255.0f
                           alpha: 1.0f];
}


+ (UIColor *) rockpacAggregateTextLight
{
    return [UIColor colorWithRed: 170.0f / 255.0f
                           green: 170.0f / 255.0f
                            blue: 170.0f / 255.0f
                           alpha: 1.0f];
}


+ (UIColor *) colorWithHex: (NSInteger) hex
{
    return [UIColor colorWithRed: ((float) ((hex & 0xFF0000) >> 16)) / 255.0
                           green: ((float) ((hex & 0xFF00) >> 8)) / 255.0
                            blue: ((float) (hex & 0xFF)) / 255.0
                           alpha: 1.0];
}


@end
