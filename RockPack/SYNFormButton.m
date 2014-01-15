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
    
    self.layer.masksToBounds = YES;
	
	self.layer.borderWidth = 1.0;
    self.layer.borderColor = [[UIColor colorWithWhite:167/255.0 alpha:1.0] CGColor];
    self.layer.cornerRadius = 8.0f;
}


@end
