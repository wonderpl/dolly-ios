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

#import <QuartzCore/QuartzCore.h>

@implementation SYNAddToChannelCreateNewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.createNewButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.createNewButton.titleLabel.font.pointSize];
    
    self.descriptionTextView.hidden = NO;
    self.descriptionTextView.alpha = 0.0f;
    
    self.createNewButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.createNewButton.layer.borderWidth = 0.5f;
    
    if(IS_IPAD)
    {
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 1.0f;
    }
    else // IS_IPHONE
    {
        // == Add two lines, one top one bottom
        
        CGRect lineFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 1.0f);
        separatorTop = [[UIView alloc] initWithFrame:lineFrame];
        
        separatorBottom = [[UIView alloc] initWithFrame:lineFrame];
        
        
        
        separatorTop.backgroundColor = [UIColor dollyTabColorSelectedBackground];
        separatorBottom.backgroundColor = [UIColor dollyTabColorSelectedBackground];
        
        [self addSubview:separatorTop];
        [self addSubview:separatorBottom];
        
    }
    
    self.descriptionTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.descriptionTextView.layer.borderWidth = 0.5f;
    
    
    
}

// set the bottom line's frame here so that it marches the variable size as it expands
-(void)layoutSubviews
{
    CGRect bottomLineFrame = separatorBottom.frame;
    bottomLineFrame.origin.y = self.frame.size.height - 1.0f;
    separatorBottom.frame = bottomLineFrame;
}

@end
