//
//  SYNCommentingCollectionViewCell.m
//  dolly
//
//  Created by Michael Michailidis on 06/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCommentingCollectionViewCell.h"
#import "Comment.h"
#import "UIButton+WebCache.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNCommentingCollectionViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.avatarButton.layer.cornerRadius = self.avatarButton.frame.size.height * 0.5f;
    
    self.nameLabel.font = [UIFont regularCustomFontOfSize:self.nameLabel.font.pointSize];
    
    self.commentLabel.font = [UIFont regularCustomFontOfSize:self.commentLabel.font.pointSize];
    
    self.timeLabel.font = [UIFont regularCustomFontOfSize:self.timeLabel.font.pointSize];
}

- (void) setComment:(Comment *)comment
{
    _comment = comment;
    
    if(!_comment)
        return;
    
    self.nameLabel.text = _comment.displayName;
    
    self.commentLabel.text = _comment.commentText;
    
    [self.avatarButton setImageWithURL: [NSURL URLWithString: comment.thumbnailUrl]
                              forState: UIControlStateNormal
                      placeholderImage: nil
                               options: SDWebImageRetryFailed];
    
}

@end
