//
//  SYNActivityTabButton.m
//  dolly
//
//  Created by Cong on 08/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNActivityTabButton.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"


@implementation SYNActivityTabButton

- (void)awakeFromNib {

    if (IS_IPAD) {
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 19, 0)];
    } else {
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 15, 0)];
    }
    
    [self.titleLabel setFont:[UIFont regularCustomFontOfSize:12]];
}

- (void) setBadageNumber:(int)badageNumber {
    NSString *strValue = [NSString stringWithFormat:@"%d", badageNumber];
    
    if (badageNumber > 0) {
        [super setTitle:strValue forState:UIControlStateNormal];
    }
}


@end
