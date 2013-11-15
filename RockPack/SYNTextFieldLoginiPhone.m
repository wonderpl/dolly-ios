//
//  SYNSYNTextFieldLoginiPhone.m
//  dolly
//
//  Created by Nick Banks on 15/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTextFieldLoginiPhone.h"

@implementation SYNTextFieldLoginiPhone

- (CGRect) editingRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 25;
    return CGRectOffset( bounds, 0, 0);

}

- (CGRect) textRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 25;
    return CGRectOffset( bounds, 0, 0);
}


@end
