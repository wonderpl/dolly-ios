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
    
    self.commentTextView.font = [SYNCommentingCollectionViewCell commentFieldFont];
    
    self.timeLabel.font = [UIFont regularCustomFontOfSize:self.timeLabel.font.pointSize];
    
    self.commentTextView.textContainerInset = UIEdgeInsetsZero;
    
    self.avatarButton.layer.cornerRadius = self.avatarButton.frame.size.height * 0.5;
    self.avatarButton.clipsToBounds = YES;
}

- (void) setComment:(Comment *)comment
{
    _comment = comment;
    
    if(!_comment)
        return;
    
    NSString* commentText = _comment.commentText;
    
    self.nameLabel.text = _comment.displayName;
    
    self.commentTextView.text = commentText;
    
    NSLog(@"%@", comment.thumbnailUrl);
    
    [self.avatarButton setImageWithURL: [NSURL URLWithString: comment.thumbnailUrl]
                              forState: UIControlStateNormal
                      placeholderImage: nil
                               options: SDWebImageRetryFailed];
    
    
}



+(UIFont*)commentFieldFont
{
    return [UIFont regularCustomFontOfSize:12.0f];
}

+(CGRect)commentFieldFrame
{
    return CGRectMake(48.0f, 28.0f, 213.0f, 18.0f);
}

@end
