//
//  SYNOnBoardingCell.m
//  dolly
//
//  Created by Michael Michailidis on 25/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+WebCache.h"

@implementation SYNOnBoardingCell

- (void) awakeFromNib
{
    
    
    self.followButton.title = NSLocalizedString(@"follow", nil);
    
}

- (void) setRecomendation:(Recomendation *)recomendation
{
    _recomendation = recomendation;
    
    self.followButton.dataItemLinked = recomendation;
    
    
    [self.avatarButton setImageWithURL: [NSURL URLWithString: recomendation.avatarUrl]
                              forState: UIControlStateNormal
                      placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarFriends"]
                               options: SDWebImageRetryFailed];
}

- (void) setDelegate:(id<SYNSocialActionsDelegate>)delegate
{
    if(_delegate)
    {
        [self.followButton removeTarget: _delegate
                                 action: @selector(followControlPressed:)
                       forControlEvents: UIControlEventTouchUpInside];
        
        [self.followButton removeTarget: _delegate
                                 action: @selector(profileButtonTapped:)
                       forControlEvents: UIControlEventTouchUpInside];
    }
    
    _delegate = delegate;
    
    if(_delegate)
    {
        [self.followButton addTarget: _delegate
                              action: @selector(followControlPressed:)
                    forControlEvents: UIControlEventTouchUpInside];
        
        [self.followButton addTarget: _delegate
                              action: @selector(profileButtonTapped:)
                    forControlEvents: UIControlEventTouchUpInside];
    }
}

@end
