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
    
    // Little hack to ensure custom font is correct
    self.contentEdgeInsets = UIEdgeInsetsMake(0.0, 2.0, 0.0, 0.0);
    
        self.titleLabel.font = [UIFont lightCustomFontOfSize: 12.0f];
    
    [self setTitleColor: UIColor.dollyButtonDefaultColor
               forState: UIControlStateNormal];
    
    [self setTitleColor: UIColor.dollyButtonHighlightedColor
               forState: UIControlStateHighlighted];
    
    [self setTitleColor: UIColor.dollyButtonSelectedColor
               forState: UIControlStateSelected];
    
    [self setTitleColor: UIColor.dollyButtonDisabledColor
               forState: UIControlStateDisabled];
    
    self.backgroundColor = [UIColor whiteColor];
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if(selected)
    {
        self.backgroundColor = self.selectedColor;
        self.layer.borderColor = self.selectedColor.CGColor;
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = self.defaultColor.CGColor;
    }
}

- (UIColor *) defaultColor
{
    return [UIColor colorWithWhite: (152.0f / 255.0f)
                             alpha: 1.0f];
}

- (UIColor *) selectedColor
{
    return [UIColor colorWithRed:(182.0f/255.0f)
                           green:(202.0f/255.0f)
                            blue:(179.0f/255.0f)
                           alpha:1.0f];
}

@end
