//
//  SYNOneToOneSharingFriendCell.h
//  rockpack
//
//  Created by Michael Michailidis on 17/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Friend.h"
@import UIKit;
@class SYNOneToOneSharingFriendCell;


@protocol SYNFriendShareCellDelegate <NSObject>

- (void)cell:(SYNOneToOneSharingFriendCell*)cell tappedWithFriend:(Friend *)friendItem;

@end

@interface SYNOneToOneSharingFriendCell : UICollectionViewCell

@property (nonatomic, weak) id<SYNFriendShareCellDelegate> delegate;

- (void)setDisplayName:(NSString*)displayName;
- (void)setFriend:(Friend*)friendItem;
- (void)setAvatarImage:(UIImage*)avatarImage;
- (void)setAvatarAlpha:(double)alpha;

@end
