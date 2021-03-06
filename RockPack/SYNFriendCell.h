//
//  SYNFriendCell.h
//  dolly
//
//  Created by Cong Le on 14/02/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

@import UIKit;
#import "SYNSearchResultsCell.h"
#import "SYNFollowChannelButton.h"

@class ChannelOwner;
@class SYNSocialButton;

@protocol SYNSearchResultsUserCellDelegate <SYNSocialActionsDelegate>

- (void)profileButtonTapped:(UIButton *)button;
- (void)followControlPressed:(SYNSocialButton *)socialButton;

@end

@interface SYNFriendCell : SYNSearchResultsCell

@property (nonatomic, strong) ChannelOwner* channelOwner;

@property (strong, nonatomic) IBOutlet SYNFollowChannelButton *followButton;

@property (nonatomic, strong, readonly) UIButton *userThumbnailButton;
@property (nonatomic, strong, readonly) UIButton *userNameLabelButton;

@end
