//
//  SYNLikeButtonControl.h
//  dolly
//
//  Created by Michael Michailidis on 25/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


typedef enum {
    SocialControlTypeDefault = 0,
    SocialControlTypeLike = 1,
    SocialControlTypeAdd
} SocialControlType;

// Superclass for the (currently) 3 buttons at the bottom of UICollectionView cells for aggregates and videos

@interface SYNSocialControl : UIControl
{
@protected
    UIButton *button;
}

+ (id) buttonControl;

- (void) commonInit ;

@property (nonatomic, readonly) UIColor *defaultColor;
@property (nonatomic, readonly) UIColor *highlightedColor;
@property (nonatomic, readonly) UIColor *selectedColor;
@property (nonatomic, readonly) UIColor *disabledColor;
@property (nonatomic, weak) NSString *title;

@property (nonatomic, weak) id dataItemLinked;

@end
