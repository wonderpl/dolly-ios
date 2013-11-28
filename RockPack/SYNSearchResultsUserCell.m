//
//  SYNSearchResultsUserCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsUserCell.h"
#import "UIFont+SYNFont.h"
#import <UIButton+WebCache.h>
#import "Friend.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNSearchResultsUserCell

- (void) awakeFromNib
{
    self.userNameLabelButton.titleLabel.font = [UIFont lightCustomFontOfSize: self.userNameLabelButton.titleLabel.font.pointSize];
    
    
    self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, 320.0f, 15.0f)];
    self.separatorView.backgroundColor = [UIColor colorWithRed:(172.0f/255.0f) green:(172.0f/255.0f) blue:(172.0f/255.0f) alpha:1.0f];
    [self addSubview:self.separatorView];
}


#pragma mark - Set Data

-(void)setDelegate:(id<SYNSocialActionsDelegate>)delegate
{
    if(_delegate)
    {
        [self.userThumbnailButton removeTarget: self.delegate
                                      action: @selector(profileButtonTapped:)
                            forControlEvents: UIControlEventTouchUpInside];
        
        [self.userNameLabelButton removeTarget: self.delegate
                                        action: @selector(profileButtonTapped:)
                              forControlEvents: UIControlEventTouchUpInside];
        
        [self.followButton removeTarget: self.delegate
                                        action: @selector(followControlPressed:)
                              forControlEvents: UIControlEventTouchUpInside];
    }
    
    _delegate = delegate;
    
    if(!_delegate)
        return;
    
    [self.userThumbnailButton addTarget: self.delegate
                                 action: @selector(profileButtonTapped:)
                       forControlEvents: UIControlEventTouchUpInside];
    
    [self.userNameLabelButton addTarget: self.delegate
                                 action: @selector(profileButtonTapped:)
                       forControlEvents: UIControlEventTouchUpInside];
    
    [self.followButton addTarget: self.delegate
                          action: @selector(followControlPressed:)
                forControlEvents: UIControlEventTouchUpInside];
}

- (void) setChannelOwner: (ChannelOwner *) channelOwner
{
    _channelOwner = channelOwner; // can be friend
    
    if (!_channelOwner)
    {
        self.userThumbnailButton.imageView.image = [UIImage imageNamed: @"PlaceholderChannelSmall.png"];
        self.userNameLabelButton.titleLabel.text = @"";
        return;
    }
    
    self.followButton.dataItemLinked = _channelOwner;
    
    
    
    [self.userThumbnailButton setImageWithURL: [NSURL URLWithString: channelOwner.thumbnailURL]
                                     forState: UIControlStateNormal
                             placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarFriends"]
                                      options: SDWebImageRetryFailed];
    
    [self.userNameLabelButton setTitle:_channelOwner.displayName forState:UIControlStateNormal];
    
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    if(IS_IPHONE)
    {
        CGRect sFrame = self.separatorView.frame;
        sFrame.origin.y = self.frame.size.height - 1.0f;
        
        self.separatorView.frame = sFrame;
        
    }
    
}

@end
