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
    
    
    if (IS_IPHONE) {
        [self.createLabel setFont:[UIFont lightCustomFontOfSize:15]];
        
    }else{
        [self.createLabel setFont:[UIFont lightCustomFontOfSize:18]];
        
    }
    [self.boarderView.layer setBorderColor:[[UIColor colorWithRed:188.0f/255.0f green:188.0f/255.0f blue:188.0f/255.0f alpha:1.0f]CGColor]];
    [self.boarderView.layer setBorderWidth:1.0f];
    
}


@end
