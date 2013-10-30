//
//  UIColor+SYNColor.h
//  RockPack
//
//  Created by Nick Banks on 15/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SYNColor)

+ (UIColor *) dollyTextDarkGray;
+ (UIColor *) dollyTextMediumGray;
+ (UIColor *) dollyTextLightGray;
+ (UIColor *) dollyTextLighterGray;

+ (UIColor *) dollyButtonDefaultColor;
+ (UIColor *) dollyButtonHighlightedColor;
+ (UIColor *) dollyButtonSelectedColor;
+ (UIColor *) dollyButtonDisabledColor;

+ (UIColor *) colorWithHex:(NSInteger)hex;

@end
