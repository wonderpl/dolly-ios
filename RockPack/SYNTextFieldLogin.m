//
//  SYNTextFieldLogin.m
//  rockpack
//
//  Created by Nick Banks on 15/11/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNTextFieldLogin.h"
#import "UIFont+SYNFont.h"

@implementation SYNTextFieldLogin

- (void) awakeFromNib
{
    float ration = (120.0f/255);
    UIColor* mediumGrayColor = [UIColor colorWithRed:ration green:ration blue:ration alpha:1.0f];
    self.layer.borderColor = mediumGrayColor.CGColor;
    self.layer.borderWidth = 1.0f;
    self.textColor = mediumGrayColor;
    self.font = [UIFont lightCustomFontOfSize:20.0f];
}

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
