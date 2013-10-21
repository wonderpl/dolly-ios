//
//  SYNOneToOneSharingFriendCell.m
//  rockpack
//
//  Created by Michael Michailidis on 17/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOneToOneSharingFriendCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNOneToOneSharingFriendCell

-(void)awakeFromNib
{
    
    self.nameLabel.font = [UIFont lightCustomFontOfSize:self.nameLabel.font.pointSize];
    
    if(!IS_IOS_7_OR_GREATER)
    {
        CGRect lFrame = self.nameLabel.frame;
        lFrame.origin.y = 72.0f;
        self.nameLabel.frame = lFrame;
    }
    
    
}

@end
