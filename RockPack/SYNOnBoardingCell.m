//
//  SYNOnBoardingCell.m
//  dolly
//
//  Created by Michael Michailidis on 25/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingCell.h"
#import "UIButton+WebCache.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNOnBoardingCell

- (void) awakeFromNib
{
    
    self.followButton.title = NSLocalizedString(@"follow", nil);
    
    self.descriptionLabel.font = [UIFont regularCustomFontOfSize:self.descriptionLabel.font.pointSize];
    
    self.nameLabel.font = [UIFont regularCustomFontOfSize:self.nameLabel.font.pointSize];
    
}

- (void) setRecomendation:(Recomendation *)recomendation
{
    
    _recomendation = recomendation;
    
    self.followButton.dataItemLinked = recomendation;
    
    self.nameLabel.text = recomendation.displayName;
    self.descriptionLabel.text = recomendation.descriptionText;
    
    
    [self.avatarButton setImageWithURL: [NSURL URLWithString: recomendation.avatarUrl]
                              forState: UIControlStateNormal
                      placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarFriends"]
                               options: SDWebImageRetryFailed];
}

- (void) setDelegate:(id<SYNSocialActionsDelegate>)delegate
{
    // avatar button is not set to receive press events yet...
    
    if(_delegate)
    {
        [self.followButton removeTarget: _delegate
                                 action: @selector(followControlPressed:)
                       forControlEvents: UIControlEventTouchUpInside];
        
    }
    
    _delegate = delegate;
    
    if(_delegate)
    {
        [self.followButton addTarget: _delegate
                              action: @selector(followControlPressed:)
                    forControlEvents: UIControlEventTouchUpInside];
        
    }
}

@end
