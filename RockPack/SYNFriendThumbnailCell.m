//
//  SYNFriendThumbnailCell.m
//  rockpack
//
//  Created by Michael Michailidis on 22/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFriendThumbnailCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNFriendThumbnailCell

@synthesize selected;

-(void)awakeFromNib
{
    
    self.nameLabel.font = [UIFont rockpackFontOfSize:self.nameLabel.font.pointSize];
    
    self.pressedLayerView.hidden = YES;
    
    
    
}

-(void)setHighlighted:(BOOL)highlighted
{
    
    if(highlighted)
    {
        self.pressedLayerView.hidden = NO;
    }
    else
    {
        self.pressedLayerView.hidden = YES;
    }
}

- (void) setDisplayName: (NSString*)name
{
    // name label //
    CGRect nameLabelFrame = self.nameLabel.frame;
    
    NSAttributedString *attributedText =  [[NSAttributedString alloc] initWithString: name
                                                                          attributes: @{NSFontAttributeName: self.nameLabel.font}];
    
    CGRect rect = [attributedText boundingRectWithSize: (CGSize){self.frame.size.width - 10.0, CGFLOAT_MAX}
                                               options: NSStringDrawingUsesLineFragmentOrigin
                                               context: nil];
    
    CGFloat height = ceilf(rect.size.height);
    CGFloat width  = ceilf(rect.size.width);
    
    CGSize correctSize = (CGSize){width, height};
    
    
    nameLabelFrame.size = correctSize;
    
    // NSLog(@"height:%f, title:%@", correctSize.height, name);
    
    nameLabelFrame.size.height = correctSize.height;
    
    self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    nameLabelFrame.origin.y = self.frame.size.height - nameLabelFrame.size.height - 8.0;
    
    self.nameLabel.frame = nameLabelFrame;
    
    self.nameLabel.text = name;
    
    
    
}



@end
