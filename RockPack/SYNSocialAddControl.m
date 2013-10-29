//
//  SYNAddControlButton.m
//  dolly
//
//  Created by Michael Michailidis on 25/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialAddControl.h"

@implementation SYNSocialAddControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        [button setImage:[UIImage imageNamed:@"IconVideoAddDefault"] forState: UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"IconVideoAddHighlighted"] forState: UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"IconVideoAddHighlighted"] forState: UIControlStateHighlighted];
        
        
    }
    return self;
}

-(UIColor*)defaultColor
{
    // override in subclass
    return [UIColor colorWithWhite: (152.0f/255.0f)
                             alpha: 1.0f];
}

-(UIColor*)highlightedColor
{
    return [UIColor colorWithWhite: (194.0f/255.0f)
                             alpha: 1.0f];
}

-(UIColor*)selectedColor
{
    return [UIColor colorWithRed:(0.0f/255.0f)
                           green:(255.0f/255.0f)
                            blue:(0.0f/255.0f)
                           alpha:1.0f];
}

@end
