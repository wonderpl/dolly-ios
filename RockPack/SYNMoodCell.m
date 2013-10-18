//
//  SYNMoodCell.m
//  dolly
//
//  Created by Nick Banks on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNMoodCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNMoodCell

- (void) awakeFromNib
{
    self.label.font = [UIFont lightCustomFontOfSize: self.label.font.pointSize];
}

@end
