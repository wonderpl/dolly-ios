//
//  SYNSegmentedButton.m
//  dolly
//
//  Created by Cong Le on 29/04/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNSegmentedButton.h"
#import "UIColor+SYNColor.h"

@implementation SYNSegmentedButton



-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected) {
		self.backgroundColor = [UIColor colorWithRed: 236.0f / 255.0f
															  green: 240.0f / 255.0f
															   blue: 241.0f / 255.0f
															  alpha: 1.0f];
	} else {
		self.backgroundColor = [UIColor whiteColor];
    }
}

@end
