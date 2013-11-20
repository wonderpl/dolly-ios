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
    
    return CGRectOffset( bounds, 10, 0);

}

- (CGRect) textRectForBounds: (CGRect) bounds
{
    
    return CGRectOffset( bounds, 10, 0);
}


@end
