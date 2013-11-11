//
//  SYNExistingChannelCell.m
//  dolly
//
//  Created by Michael Michailidis on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAddToChannelCell.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNAddToChannelCell


-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 1.0f;
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
}

-(void)setSelected:(BOOL)selected
{
    if(selected)
    {
        self.backgroundColor = [UIColor greenColor];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    
}
@end
