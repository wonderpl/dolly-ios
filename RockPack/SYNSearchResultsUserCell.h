//
//  SYNSearchResultsUserCell.h
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import UIKit;
#import "SYNSearchResultsCell.h"

@class ChannelOwner;
@class SYNSocialButton;

@protocol SYNSearchResultsUserCellDelegate <SYNSocialActionsDelegate>

- (void)profileButtonTapped:(UIButton *)button;
- (void)followControlPressed:(UIButton *)button;

@end

@interface SYNSearchResultsUserCell : SYNSearchResultsCell

@property (nonatomic, strong) ChannelOwner* channelOwner;
@property (nonatomic, strong, readonly) SYNSocialButton *followButton;

@end
