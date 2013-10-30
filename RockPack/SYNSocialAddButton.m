//
//  SYNAddControlButton.m
//  dolly
//
//  Created by Michael Michailidis on 25/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialAddButton.h"

@implementation SYNSocialAddButton



- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self setImage:[UIImage imageNamed:@"IconVideoAddDefault"] forState: UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"IconVideoAddHighlighted"] forState: UIControlStateSelected];
    [self setImage:[UIImage imageNamed:@"IconVideoAddHighlighted"] forState: UIControlStateHighlighted];
}

-(UIColor*)defaultColor
{
    
    return [UIColor colorWithRed:(224.0f/255.0f)
                           green:(92.0f/255.0f)
                            blue:(72.0f/255.0f)
                           alpha:1.0f];
}

-(UIColor*)highlightedColor
{
    return [UIColor colorWithRed:(224.0f/255.0f)
                           green:(92.0f/255.0f)
                            blue:(72.0f/255.0f)
                           alpha:1.0f];
}

-(UIColor*)selectedColor
{
    return [UIColor colorWithRed:(224.0f/255.0f)
                           green:(92.0f/255.0f)
                            blue:(72.0f/255.0f)
                           alpha:1.0f];
}

@end
