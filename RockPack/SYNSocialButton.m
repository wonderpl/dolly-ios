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
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont lightCustomFontOfSize: 12.0f];
    
    // Little hack to ensure custom font is correctly 
    self.contentEdgeInsets = UIEdgeInsetsMake(0.0, 2.0, 0.0, 0.0);
    
    self.layer.cornerRadius = self.frame.size.height * 0.5;
    self.layer.borderColor = [UIColor.dollyButtonDefaultColor CGColor];
    self.layer.borderWidth = 1.0f;
    
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


- (void) setTitle: (NSString *) title
{
    [self setTitle: title
          forState: UIControlStateNormal];
}


- (void) setTitle: (NSString *) title
         andCount: (NSInteger) count
{
    NSString *countString = @" ";
    
    if (count > 0)
    {
        countString = [NSString stringWithFormat: @"%d", count];
    }
    
    [self setTitle:  [NSString stringWithFormat: @"\n%@\n%@", title, countString]
                       forState: UIControlStateNormal];
}

@end
