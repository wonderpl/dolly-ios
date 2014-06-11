//
//  UIColor+SYNColor.h
//  RockPack
//
//  Created by Nick Banks on 15/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

@import UIKit;

@interface UIColor (SYNColor)

+ (UIColor *) dollyTextDarkGray;
+ (UIColor *) dollyTextMediumGray;
+ (UIColor *) dollyTextLightGray;
+ (UIColor *) dollyTextLighterGray;

+ (UIColor *) dollyButtonDefaultColor;
+ (UIColor *) dollyButtonHighlightedColor;
+ (UIColor *) dollyButtonSelectedColor;
+ (UIColor *) dollyButtonDisabledColor;

+ (UIColor *) dollyAddButtonDefaultColor;
+ (UIColor *) dollyAddButtonHighlightedColor;
+ (UIColor *) dollyAddButtonSelectedColor;
+ (UIColor *) dollyAddButtonDisabledColor;
+ (UIColor *) dollyMediumGray;

+ (UIColor *) colorWithHex:(NSInteger)hex;
+ (UIColor *) dollyActivityIndicator;

+ (UIColor *) dollyTabColorSelectedBackground;
+ (UIColor *) dollyTabColorSelectedText;
+ (UIColor *) dollyMoodColor;
+ (UIColor *) dollyGreen;
+ (UIColor *) dollyBlue;
+ (UIColor *) dollyRed;

+ (UIColor *) dollySearchBarColor;

+ (UIColor *) dollyButtonGreenColor;
+ (UIColor *) dollySegmentedColor;
+ (UIColor *) facebookColor;
+ (UIColor *) lighterColorForColor:(UIColor *)c;
+ (UIColor *) darkerColorForColor:(UIColor *)c;

+ (UIColor *)defaultCategoryColor;

@end
