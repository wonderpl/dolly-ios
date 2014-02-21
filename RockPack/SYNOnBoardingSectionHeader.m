//
//  SYNOnBoardingSectionHeader.m
//  dolly
//
//  Created by Cong on 21/01/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNOnBoardingSectionHeader.h"
#import "UIFont+SYNFont.h"

@implementation SYNOnBoardingSectionHeader

- (void) awakeFromNib
{
    self.sectionTitle.font = [UIFont lightCustomFontOfSize:self.sectionTitle.font.pointSize];
    self.sectionTitle.textColor = [UIColor blackColor];
    
    
}

@end
