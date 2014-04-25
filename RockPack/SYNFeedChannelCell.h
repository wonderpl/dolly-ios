//
//  SYNFeedChannelCell.h
//  dolly
//
//  Created by Sherman Lo on 16/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Channel;
@class SYNFeedChannelCell;

@protocol SYNFeedChannelCellDelegate <NSObject>

- (void)channelCellAvatarPressed:(SYNFeedChannelCell *)cell;
- (void)channelCellTitlePressed:(SYNFeedChannelCell *)cell;

@end

@interface SYNFeedChannelCell : UICollectionViewCell

@property (nonatomic, strong) Channel *channel;

@property (nonatomic, weak) id<SYNFeedChannelCellDelegate> delegate;

@end
