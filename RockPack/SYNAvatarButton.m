//
//  SYNAvatarButton.m
//  dolly
//
//  Created by Nick Banks on 07/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAvatarButton.h"

@implementation SYNAvatarButton

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = self.frame.size.height * 0.5;
}

@end
