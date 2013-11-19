/**
 * @class      OOClosedCaptionsStyle OOClosedCaptionsStyle.h "OOClosedCaptionsStyle.h"
 * @brief      OOClosedCaptionsStyle
 * @details    OOClosedCaptionsStyle.h in OoyalaSDK
 * @author     Chris Leonavicius
 * @date       1/31/12
 * @copyright  Copyright (c) 2012 Ooyala, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Defines text style to be used when displaying closed captions.
 */
@interface OOClosedCaptionsStyle : NSObject

/**
 * Creates a new closed caption style
 * @param[in] color Text color to use
 * @param[in] backgroundColor Background color to use
 * @param[in] font Text font to use
 */
- (id)initWithColor:(UIColor *)color backgroundColor:(UIColor *)backgroundColor font:(UIFont *)font;

/** Closed captions color */
@property (nonatomic, strong) UIColor *color;

/** Closed captions background color */
@property (nonatomic, strong) UIColor *backgroundColor;

/** Closed captions font */
@property (nonatomic, strong) UIFont *font;

@end
