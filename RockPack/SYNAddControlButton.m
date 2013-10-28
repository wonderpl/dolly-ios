//
//  SYNAddControlButton.m
//  dolly
//
//  Created by Michael Michailidis on 25/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAddControlButton.h"

@implementation SYNAddControlButton

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



@end
