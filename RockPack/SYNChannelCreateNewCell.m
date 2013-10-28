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
    
    [self.createLabel setFont:[UIFont lightCustomFontOfSize:18]];
    
    [self.boarderView.layer setBorderColor:[[UIColor grayColor]CGColor]];
    [self.boarderView.layer setBorderWidth:1.0f];
}


@end
