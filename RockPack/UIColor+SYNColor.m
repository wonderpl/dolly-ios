//
//  UIColor+SYNColor.m
//  RockPack
//
//  Created by Nick Banks on 15/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "UIColor+SYNColor.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define WA(w,a) [UIColor colorWithWhite:w/255.0 alpha:a]

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
    return RGB(119, 119, 130);
}

+ (UIColor *) dollyTextLightGray
{
    return [UIColor colorWithRed: 152.0f / 255.0f
                           green: 152.0f / 255.0f
                            blue: 152.0f / 255.0f
                           alpha: 1.0f];
}


+ (UIColor *) dollyTextLighterGray
{
    return [UIColor colorWithRed: 188.0f / 255.0f
                           green: 188.0f / 255.0f
                            blue: 188.0f / 255.0f
                           alpha: 1.0f];
}

+ (UIColor *) dollyMediumGray
{
    return [UIColor colorWithRed: 172.0f / 255.0f
                           green: 172.0f / 255.0f
                            blue: 172.0f / 255.0f
                           alpha: 1.0f];
}


+ (UIColor *) dollyButtonDefaultColor
{
    // override in subclass
    return [UIColor colorWithWhite: (152.0f / 255.0f)
                             alpha: 1.0f];
}


+ (UIColor *) dollyButtonHighlightedColor
{
    return [UIColor colorWithWhite: (194.0f / 255.0f)
                             alpha: 1.0f];
}


+ (UIColor *) dollyButtonSelectedColor
{
    return [UIColor colorWithRed: (0.0f / 255.0f)
                           green: (255.0f / 255.0f)
                            blue: (0.0f / 255.0f)
                           alpha: 1.0f];
}


+ (UIColor *) dollyButtonDisabledColor
{
    // override in subclass
    return [UIColor colorWithWhite: (152.0f / 255.0f)
                             alpha: 0.5f];
}


+ (UIColor *) dollyAddButtonDefaultColor
{
    return [UIColor colorWithRed: (224.0f / 255.0f)
                           green: (92.0f / 255.0f)
                            blue: (72.0f / 255.0f)
                           alpha: 1.0f];
}

+ (UIColor *) dollyAddButtonHighlightedColor
{
    return [UIColor colorWithRed: (224.0f / 255.0f)
                           green: (92.0f / 255.0f)
                            blue: (72.0f / 255.0f)
                           alpha: 1.0f];
}


+ (UIColor *) dollyAddButtonSelectedColor
{
    return [UIColor colorWithRed: (224.0f / 255.0f)
                           green: (92.0f / 255.0f)
                            blue: (72.0f / 255.0f)
                           alpha: 1.0f];
}


+ (UIColor *) dollyAddButtonDisabledColor
{
    // override in subclass
    return [UIColor colorWithWhite: (152.0f / 255.0f)
                             alpha: 0.5f];
}

+ (UIColor *) colorWithHex: (NSInteger) hex
{
    return [UIColor colorWithRed: ((float) ((hex & 0xFF0000) >> 16)) / 255.0
                           green: ((float) ((hex & 0xFF00) >> 8)) / 255.0
                            blue: ((float) (hex & 0xFF)) / 255.0
                           alpha: 1.0];
}



+ (UIColor *) dollyTabColorSelectedBackground
{
    return [UIColor colorWithWhite:152/255.0f alpha:1.0];
}


+(UIColor *) dollyTabColorSelectedText
{
   return [UIColor colorWithRed:130.0f/255.0f
                    green:130.0f/255.0f
                     blue:130.0f/255.0f
                    alpha:1];
    
}

+(UIColor *) dollyActivityIndicator
{
    return [UIColor colorWithRed: 188.0f / 255.0f
                           green: 186.0f / 255.0f
                            blue: 212.0f / 255.0f
                           alpha: 1.0f];
}

+(UIColor *) dollyMoodColor
{
return [UIColor colorWithRed: 136.0f / 255.0f
                green: 134.0f / 255.0f
                 blue: 168.0f / 255.0f
                alpha: 1.0f];
}

+ (UIColor *)facebookColor {
	return RGB(61, 90, 151);
}


+ (UIColor *) dollySearchBarColor
{
   return [UIColor colorWithRed: (196.0f / 255.0f)
                    green: (196.0f / 255.0f)
                     blue: (196.0f / 255.0f)
                    alpha: 1.0f];
}

+ (UIColor *)lighterColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.1, 1.0)
                               green:MIN(g + 0.1, 1.0)
                                blue:MIN(b + 0.1, 1.0)
                               alpha:a];
    return nil;
}

+ (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.1, 0.0)
                               green:MAX(g - 0.1, 0.0)
                                blue:MAX(b - 0.1, 0.0)
                               alpha:a];
    return nil;
}

+ (UIColor *)defaultCategoryColor {
	return WA(200, 1);
}

@end
