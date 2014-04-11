//
//  SYNFollowUserButton.m
//  dolly
//
//  Created by Cong on 07/01/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNFollowDiscoverButton.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"

@implementation SYNFollowDiscoverButton


-(void)awakeFromNib
{
    [super awakeFromNib];
    
	self.backgroundColor = [UIColor clearColor];
	
}

- (UIColor*) selectedColor {
	return [UIColor whiteColor];
}

- (UIColor*) defaultColor {
	return [UIColor whiteColor];
}


@end
