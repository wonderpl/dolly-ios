//
//  SYNRoundButton.m
//  dolly
//
//  Created by Nick Banks on 30/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialButton.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"

@implementation SYNSocialButton

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = self.frame.size.height * 0.5;
    self.layer.borderColor = self.defaultColor.CGColor;
    self.layer.borderWidth = 1.0f;
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize:13.0f];
    
    [self setTitleColor: [UIColor dollyButtonDefaultColor]
               forState: UIControlStateNormal];
    
    [self setTitleColor: [UIColor dollyButtonHighlightedColor]
               forState: UIControlStateHighlighted];
    
    [self setTitleColor: [UIColor dollyButtonDefaultColor]
               forState: UIControlStateSelected];
    
    [self setTitleColor: [UIColor dollyButtonDisabledColor]
               forState: UIControlStateDisabled];
    
    self.backgroundColor = [UIColor whiteColor];
}



- (UIColor *) defaultColor
{
    return [UIColor colorWithWhite: (152.0f / 255.0f)
                             alpha: 1.0f];
}

- (UIColor *) selectedColor
{
    return [UIColor colorWithWhite: (152.0f / 255.0f)
                             alpha: 1.0f];
}

@end
