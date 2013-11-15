//
//  SYNFormButton.m
//  dolly
//
//  Created by Nick Banks on 15/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFormButton.h"

@implementation SYNFormButton

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 4.0f;
    self.layer.masksToBounds = YES;
}


@end
