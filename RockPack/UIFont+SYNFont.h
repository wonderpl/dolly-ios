//
//  UIFont+SYNFont.h
//  RockPack
//
//  Created by Nick Banks on 15/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

@import UIKit;

@interface UIFont (SYNFont)

+ (UIFont *)lightCustomFontOfSize:(CGFloat)fontSize;
+ (UIFont *)regularCustomFontOfSize:(CGFloat)fontSize;
+ (UIFont *)semiboldCustomFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldCustomFontOfSize:(CGFloat)fontSize;

+ (UIFont *)regularAlternateFontOfSize:(CGFloat)fontSize;
+ (UIFont *)italicAlternateFontOfSize:(CGFloat)fontSize;

@end
