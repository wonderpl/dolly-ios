//
//  SYNChannelCreateNewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelCreateNewCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNChannelCreateNewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
}


@end
