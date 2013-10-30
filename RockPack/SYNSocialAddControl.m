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
