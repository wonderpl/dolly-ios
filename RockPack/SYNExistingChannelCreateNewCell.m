//
//  SYNChannelCreateNewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNExistingChannelCreateNewCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNExistingChannelCreateNewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    
    self.createNewButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.createNewButton.titleLabel.font.pointSize];

}


@end