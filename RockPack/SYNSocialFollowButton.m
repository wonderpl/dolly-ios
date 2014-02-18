//
//  SYNSocialFollowButton.m
//  dolly
//
//  Created by Michael Michailidis on 04/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialFollowButton.h"
#import "UIColor+SYNColor.h"

@implementation SYNSocialFollowButton

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setTitle:NSLocalizedString(@"follow", nil)];
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if(selected)
    {
        self.layer.borderColor = [[self selectedBorderColor] CGColor];
        [self setTitle:NSLocalizedString(@"unfollow", nil)];
        [self setTitleColor: [self selectedBorderColor]
                   forState: UIControlStateSelected];
    
        
        
    }
    else
    {
        self.layer.borderColor = self.defaultColor.CGColor;
        
        [self setTitle:NSLocalizedString(@"follow", nil)];
        
        [self setTitleColor: [UIColor dollyButtonDefaultColor]
                   forState: UIControlStateNormal];
    }
}

- (UIColor *) selectedColor
{
    return [UIColor colorWithRed:(188.0f/255.0f)
                           green:(186.0f/255.0f)
                            blue:(212.0f/255.0f)
                           alpha:1.0f];
}
- (UIColor *) selectedBorderColor
{
    return [UIColor colorWithRed:(146.0f/255.0f)
                           green:(143.0f/255.0f)
                            blue:(183.0f/255.0f)
                           alpha:1.0f];
}

@end
