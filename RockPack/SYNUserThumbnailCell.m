//
//  SYNUserThumbnailCell.m
//  rockpack
//
//  Created by Michael Michailidis on 08/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUserThumbnailCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
@import QuartzCore;

@implementation SYNUserThumbnailCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.nameLabel.font = [UIFont lightCustomFontOfSize: self.nameLabel.font.pointSize];
    self.usernameLabel.font = [UIFont lightCustomFontOfSize: self.usernameLabel.font.pointSize];
    
    self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.nameLabel.numberOfLines = 2;
    
    float gray_ratio = (183.0f/255.0f);
    self.usernameLabel.textColor = [UIColor colorWithRed:gray_ratio green:gray_ratio blue:gray_ratio alpha:1.0];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = UIScreen.mainScreen.scale;
    
    
    
}

-(void)setDisplayName:(NSString*)name andUsername:(NSString*)username
{
    
    // name label //
    
    CGRect nameLabelFrame = self.nameLabel.frame;
    CGRect usernameLabelFrame = self.usernameLabel.frame;
    
    if(IS_IPAD)
    {
        NSAttributedString *attributedText =  [[NSAttributedString alloc] initWithString: name
                                                                              attributes: @{NSFontAttributeName: self.nameLabel.font}];
        
        CGRect rect = [attributedText boundingRectWithSize: (CGSize){self.frame.size.width, CGFLOAT_MAX}
                                                   options: NSStringDrawingUsesLineFragmentOrigin
                                                   context: nil];
        
        CGFloat height = ceilf(rect.size.height);
        CGFloat width  = ceilf(rect.size.width);
        
        CGSize correctSize = (CGSize){width, height};
        
        
        nameLabelFrame.size = correctSize;
        
        
        if(nameLabelFrame.size.height > 30.0)
        {
            nameLabelFrame.size.height = 30.0;
            self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        
        usernameLabelFrame.origin.y = nameLabelFrame.origin.y + nameLabelFrame.size.height - 6.0;
    }
    
    
    
    self.nameLabel.frame = nameLabelFrame;
    
    self.nameLabel.text = name;
    
    // username label //
    
    self.usernameLabel.text = username;
    [self.usernameLabel sizeToFit];
    
    
    self.usernameLabel.frame = usernameLabelFrame;
    
}

-(void)setImageUrlString:(NSString *)imageUrlString
{
    
    if(!imageUrlString || [imageUrlString isEqualToString:@""]) // cancel the existing network operation
    {
        [self.imageView setImageWithURL: nil
                       placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                options: SDWebImageRetryFailed];
    }
    
    
    [self.imageView setImageWithURL: [NSURL URLWithString: imageUrlString]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                            options: SDWebImageRetryFailed];
    
}


@end
