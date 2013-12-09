//
//  SYNCommentingCollectionViewCell.m
//  dolly
//
//  Created by Michael Michailidis on 06/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCommentingCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNCommentingCollectionViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height * 0.5f;
    
    
    
}


@end
