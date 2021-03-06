//
//  SYNOnBoardingCell.h
//  dolly
//
//  Created by Michael Michailidis on 25/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNSocialActionsDelegate.h"
#import "SYNAvatarButton.h"
#import "SYNSocialButton.h"
#import "SYNFollowChannelButton.h"

@class Recommendation;
@interface SYNOnBoardingCell : UICollectionViewCell
{
    CGPoint nameLabelOrigin;
    CGPoint subGenreLabelOrigin;
}

// avatar button is currently used as an image only but can change to accomodate press events
@property (nonatomic, strong) IBOutlet SYNAvatarButton* avatarButton;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UILabel* descriptionLabel;
@property (nonatomic, strong) IBOutlet SYNFollowChannelButton *followButton;
@property (strong, nonatomic) IBOutlet UIView *bottomBorderView;

@property (nonatomic, weak) ChannelOwner* channelOwner;
@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;
@property (nonatomic, weak) Recommendation* recommendation;

@end
