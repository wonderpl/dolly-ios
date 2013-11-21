//
//  SYNOneToOneSharingFriendCell.m
//  rockpack
//
//  Created by Michael Michailidis on 17/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOneToOneSharingFriendCell.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNOneToOneSharingFriendCell

-(void)awakeFromNib
{
    
    self.nameLabel.font = [UIFont lightCustomFontOfSize:self.nameLabel.font.pointSize];
    
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width * 0.5;
    
    
}


- (void) setDisplayName: (NSString*) displayName
{
    if(!displayName)
    {
        self.nameLabel.text = @"";
        return;
    }
    CGRect currentNameLabelFrame = self.nameLabel.frame;
    
    self.nameLabel.text = displayName;
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:displayName
                                                                         attributes:@{NSFontAttributeName: self.nameLabel.font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.frame.size.width, 26.0f}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    
  
    
    currentNameLabelFrame.origin.y = 56.0f;
    currentNameLabelFrame.size.height = rect.size.height;
    
    self.nameLabel.frame = currentNameLabelFrame;
}
@end
