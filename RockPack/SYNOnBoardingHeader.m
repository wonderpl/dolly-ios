//
//  SYNOnBoardingHeader.m
//  dolly
//
//  Created by Michael Michailidis on 25/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingHeader.h"
#import "UIFont+SYNFont.h"

@implementation SYNOnBoardingHeader

- (void) awakeFromNib
{
    self.textLabel.font = [UIFont regularCustomFontOfSize:self.textLabel.font.pointSize];
    
    self.titleLabel.font = [UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize];
    
    
}

@end
