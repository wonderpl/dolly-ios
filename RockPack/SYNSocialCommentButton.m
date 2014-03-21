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
    
    
    [self setBackgroundImage: [UIImage imageNamed: @"IconVideoCommentDefault"]
                    forState: UIControlStateNormal];
    
    [self setBackgroundImage: [UIImage imageNamed: @"IconVideoCommentHighlighted"]
                    forState: UIControlStateSelected];
    
    [self setBackgroundImage: [UIImage imageNamed: @"IconVideoCommentHighlighted"]
                    forState: UIControlStateHighlighted];
    
    UIColor* greenLightColor = [UIColor colorWithRed:(182.0f/255.0f)
                                               green:(202.0f/255.0f)
                                                blue:(177.0f/255.0f)
                                               alpha:1.0f];
    
    [self setTitleColor: greenLightColor
               forState: UIControlStateNormal];
    
    [self setTitleColor: greenLightColor
               forState: UIControlStateHighlighted];
    
    [self setTitleColor: greenLightColor
               forState: UIControlStateSelected];
    
    [self setTitleColor: greenLightColor
               forState: UIControlStateDisabled];
    
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

- (void)setCount:(NSUInteger)count {
	_count = count;

	if (count == 0) {
		[self setTitle:@"" forState:UIControlStateNormal];
	} else if (count < 100) {
		[self setTitle:[NSString stringWithFormat:@"%@", @(count)] forState:UIControlStateNormal];
	} else {
		[self setTitle:@"99+" forState:UIControlStateNormal];
	}
}

@end
