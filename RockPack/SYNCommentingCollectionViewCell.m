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
    
    self.commentLabel.font = [SYNCommentingCollectionViewCell commentFieldFont];
    
    self.timeLabel.font = [UIFont regularCustomFontOfSize:self.timeLabel.font.pointSize];
}

- (void) setComment:(Comment *)comment
{
    _comment = comment;
    
    if(!_comment)
        return;
    
    NSString* commentText = _comment.commentText;
    
    self.nameLabel.text = _comment.displayName;
    
    self.commentLabel.text = commentText;
    
    [self.avatarButton setImageWithURL: [NSURL URLWithString: comment.thumbnailUrl]
                              forState: UIControlStateNormal
                      placeholderImage: nil
                               options: SDWebImageRetryFailed];
    
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.commentLabel sizeToFit];
}

+(UIFont*)commentFieldFont
{
    return [UIFont regularCustomFontOfSize:12.0f];
}

+(CGRect)commentFieldFrame
{
    return CGRectMake(48.0f, 28.0f, 200.0f, 21.0f);
}

@end
