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
#import "SYNGenreColorManager.h"

@implementation SYNOnBoardingCell

- (void) awakeFromNib
{
    
    
    
    self.descriptionLabel.font = [UIFont regularCustomFontOfSize:self.descriptionLabel.font.pointSize];
    self.subGenreLabel.font = [UIFont regularCustomFontOfSize:self.subGenreLabel.font.pointSize];
    self.nameLabel.font = [UIFont regularCustomFontOfSize:self.nameLabel.font.pointSize];
    
    // store the values as read from the XIB file
    nameLabelOrigin = self.nameLabel.frame.origin;
    subGenreLabelOrigin = self.subGenreLabel.frame.origin;
    
    // only iPhone cells have the separator at the bottom
    if(IS_IPHONE)
    {
        CGRect bottomBorderFrame = self.bottomBorderView.frame;
        bottomBorderFrame.size.height = IS_RETINA ? 0.5f : 1.0f;
        self.bottomBorderView.frame = bottomBorderFrame;
    }
    
    
}

-(void)prepareForReuse
{
    // labels could have been moved due to description text missing;
    CGRect rect = self.nameLabel.frame;
    rect.origin = nameLabelOrigin;
    self.nameLabel.frame = rect;
    
    rect = self.subGenreLabel.frame;
    rect.origin = subGenreLabelOrigin;
    self.subGenreLabel.frame = rect;
    [self.subGenreLabel setBackgroundColor:[UIColor clearColor]];
    
    self.descriptionLabel.hidden = NO;
}

- (void) setRecomendation:(Recomendation *)recomendation
{
    
    if(!recomendation)
        return;
    
    _recomendation = recomendation;
    
    self.followButton.dataItemLinked = recomendation.channelOwner;
    
    self.nameLabel.text = recomendation.displayName;
    
    recomendation.descriptionText = recomendation.descriptionText;
    
    if (IS_IPAD) {
        [self.subGenreLabel setBackgroundColor:[[SYNGenreColorManager sharedInstance] colorFromID:recomendation.categoryId]];
    }
    
    if([recomendation.descriptionText isEqualToString:@""]) // there is no description
    {
        // == squash the tet fields down when we have no text == //
        
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.nameLabel.center.y + 14.0f);
        
        self.subGenreLabel.center = CGPointMake(self.subGenreLabel.center.x, self.subGenreLabel.center.y - 14.0f);
        
        self.descriptionLabel.hidden = YES;
    }
    else
    {
        self.descriptionLabel.text = recomendation.descriptionText;
    }
    
    
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
