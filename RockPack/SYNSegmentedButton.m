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

-(void)awakeFromNib {
    [super awakeFromNib];
    
    
    [self setTitleColor: [UIColor dollySegmentedColor]
               forState: UIControlStateNormal];
    [self setTitleColor: [UIColor whiteColor]
               forState: UIControlStateSelected];
}


-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected) {
		self.backgroundColor = [UIColor dollySegmentedColor];
	} else {
		self.backgroundColor = [UIColor whiteColor];
    }
}

@end
