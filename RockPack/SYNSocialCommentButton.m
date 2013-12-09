//
//  SYNSocialCommentButton.m
//  dolly
//
//  Created by Michael Michailidis on 06/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialCommentButton.h"

@implementation SYNSocialCommentButton

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    // Reset these as we are using an image
    self.contentEdgeInsets = UIEdgeInsetsMake(0.0, 1.0, 0.0, 0.0);
    
    [self setImage: [UIImage imageNamed: @"IconVideoAddDefault"]
          forState: UIControlStateNormal];
    
    [self setImage: [UIImage imageNamed: @"IconVideoAddHighlighted"]
          forState: UIControlStateSelected];
    
    [self setImage: [UIImage imageNamed: @"IconVideoAddHighlighted"]
          forState: UIControlStateHighlighted];
}


- (UIColor *) highlightedColor
{
    return [UIColor colorWithRed: (224.0f / 255.0f)
                           green: (92.0f / 255.0f)
                            blue: (72.0f / 255.0f)
                           alpha: 1.0f];
}


- (UIColor *) selectedColor
{
    return [UIColor colorWithRed: (224.0f / 255.0f)
                           green: (92.0f / 255.0f)
                            blue: (72.0f / 255.0f)
                           alpha: 1.0f];
}

#pragma mark - Set / Get Count

- (void) setCount:(NSInteger)count
{
    _count = count;
    
    if(_count < 100)
        [self setTitle:[NSString stringWithFormat:@"%i", count]];
    else
        [self setTitle:[NSString stringWithFormat:@"%i+", count]];
}

@end
