//
//  SYNSearchResultsUserCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsUserCell.h"
#import "UIFont+SYNFont.h"
#import "UIButton+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNSearchResultsUserCell

- (void) awakeFromNib
{
    self.userNameLabelButton.titleLabel.font = [UIFont lightCustomFontOfSize: self.userNameLabelButton.titleLabel.font.pointSize];
    
    
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
    _channelOwner = channelOwner;
    
    if (!_channelOwner)
    {
        self.userThumbnailButton.imageView.image = [UIImage imageNamed: @"PlaceholderChannelSmall.png"];
        self.userNameLabelButton.titleLabel.text = @"";
        return;
    }
    
    
    self.followButton.dataItemLinked = _channelOwner;
    
    
    [self.userThumbnailButton setImageWithURL: [NSURL URLWithString: channelOwner.thumbnailURL]
                                     forState: UIControlStateNormal
                             placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                      options: SDWebImageRetryFailed];
    
    
    self.userNameLabelButton.titleLabel.text = _channelOwner.displayName;
}



@end
