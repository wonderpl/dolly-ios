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
        self.backgroundColor = self.selectedColor;
        self.layer.borderColor = self.selectedColor.CGColor;
        [self setTitle:NSLocalizedString(@"unfollow", nil)];
    
        
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = self.defaultColor.CGColor;
        
        [self setTitle:NSLocalizedString(@"follow", nil)];
        
        [self setTitleColor: [UIColor dollyButtonDefaultColor]
                   forState: UIControlStateNormal];
    }
}

- (UIColor *) selectedColor
{
    return [UIColor colorWithRed:(182.0f/255.0f)
                           green:(202.0f/255.0f)
                            blue:(179.0f/255.0f)
                           alpha:1.0f];
}

@end
