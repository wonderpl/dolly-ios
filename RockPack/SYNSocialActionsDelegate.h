//
//  SYNSocialActionsDelegate.h
//  dolly
//
//  Created by Michael Michailidis on 28/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialButton.h"

@import Foundation;

@class ChannelOwner;

@protocol SYNSocialActionsDelegate <NSObject>

- (void)followControlPressed:(UIButton *)button withChannelOwner:(ChannelOwner *)channelOwner completion :(void (^)(void))callbackBlock;
- (void) shareControlPressed: (SYNSocialButton *) socialButton;
- (void) likeControlPressed: (SYNSocialButton *) socialButton;
- (void) addControlPressed: (SYNSocialButton *) socialButton;

//need to change
@optional
- (void) videoButtonPressed: (id) cell;
- (void) channelControlPressed: (UICollectionViewCell *) cell;
@end
