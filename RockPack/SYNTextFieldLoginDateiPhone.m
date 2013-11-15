//
//  SYNTextFieldLoginDateiPhone.m
//  dolly
//
//  Created by Nick Banks on 15/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTextFieldLoginDateiPhone.h"

@implementation SYNTextFieldLoginDateiPhone

- (CGRect) placeholderRectForBounds: (CGRect) bounds
{
    return CGRectOffset( bounds, 10,  0);
}

- (CGRect) editingRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 20;
    return CGRectOffset( bounds, 10, 0);
}

- (CGRect) textRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 20;
    return CGRectOffset( bounds , 10 , 0);
}

@end
