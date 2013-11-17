//
//  SYNTextFieldLogin.m
//  rockpack
//
//  Created by Nick Banks on 15/11/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNTextFieldLogin.h"

@implementation SYNTextFieldLogin

- (CGRect) placeholderRectForBounds: (CGRect) bounds
{
    return CGRectOffset( bounds, 10,  0);
}

- (CGRect) editingRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 35;
    return CGRectOffset( bounds, 10, 0);
}

- (CGRect) textRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 35;
    return CGRectOffset( bounds , 10 , 0);
}

@end
