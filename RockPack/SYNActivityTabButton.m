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
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 7, 24, 0)];
    } else {
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 14, 0)];
    }
    
    [self.titleLabel setFont:[UIFont regularCustomFontOfSize:12]];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void) setBadageNumber:(int)badageNumber {
    
    NSString *strValue = [NSString stringWithFormat:@"%d", badageNumber];
    if (badageNumber > 0) {
        [super setTitle:strValue forState:UIControlStateNormal];
    } else if (badageNumber == 0) {
        [super setTitle:@"" forState:UIControlStateNormal];
        [super setTitle:@"" forState:UIControlStateSelected];
    }
}


@end
