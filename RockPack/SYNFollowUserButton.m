//
//  SYNFollowUserButton.m
//  dolly
//
//  Created by Cong on 07/01/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNFollowUserButton.h"
#import "UIColor+SYNColor.h"

@implementation SYNFollowUserButton


-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setTitle:NSLocalizedString(@"follow", nil)];
}

-(void)setSelected:(BOOL)selected
{
//    [super setSelected:selected];
    
    if(selected)
    {
        [self setTitle:NSLocalizedString(@"unfollow", nil)];
    }
    else
    {
        
        [self setTitle:NSLocalizedString(@"follow", nil)];
    }
}

//- (UIColor *) selectedColor
//{
//    return [UIColor colorWithRed:(182.0f/255.0f)
//                           green:(202.0f/255.0f)
//                            blue:(179.0f/255.0f)
//                           alpha:1.0f];
//}
//

@end
