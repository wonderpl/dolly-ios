//
//  UIColor+SYNColor.m
//  RockPack
//
//  Created by Nick Banks on 15/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "UIColor+SYNColor.h"

@implementation UIColor (SYNColor)


+ (UIColor *) dollyTextDarkGray
{
    return [UIColor colorWithRed: 70.0f / 255.0f
                           green: 70.0f / 255.0f
                            blue: 70.0f / 255.0f
                           alpha: 1.0f];
}

+ (UIColor *) dollyTextMediumGray
{
    return [UIColor colorWithRed: 120.0f / 255.0f
                           green: 120.0f / 255.0f
                            blue: 120.0f / 255.0f
                           alpha: 1.0f];
}


+ (UIColor *) dollyTextLigthGray
{
    return [UIColor colorWithRed: 152.0f / 255.0f
                           green: 152.0f / 255.0f
                            blue: 152.0f / 255.0f
                           alpha: 1.0f];
}

+ (UIColor *) dollyTextLigtherGray
{
    return [UIColor colorWithRed: 188.0f / 255.0f
                           green: 188.0f / 255.0f
                            blue: 188.0f / 255.0f
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
