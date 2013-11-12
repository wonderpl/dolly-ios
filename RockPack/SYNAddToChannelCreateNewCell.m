//
//  SYNChannelCreateNewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAddToChannelCreateNewCell.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"

@implementation SYNAddToChannelCreateNewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.createNewButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.createNewButton.titleLabel.font.pointSize];
    self.backgroundColor = [UIColor dollyAddButtonDefaultColor];
    
    self.descriptionTextView.hidden = NO;
    self.descriptionTextView.alpha = 0.0f;
}


@end
