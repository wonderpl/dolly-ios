//
//  SYNFeedVideoCell.h
//  dolly
//
//  Created by Sherman Lo on 15/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNVideoInfoCell.h"

@class VideoInstance;
@class SYNVideoActionsBar;
@class SYNFeedVideoCell;

@protocol SYNFeedVideoCellDelegate <NSObject>

- (void)videoCellAvatarPressed:(SYNFeedVideoCell *)cell;
- (void)videoCellThumbnailPressed:(SYNFeedVideoCell *)cell;

- (void)videoCellFavouritePressed:(SYNFeedVideoCell *)cell;
- (void)videoCellAddToChannelPressed:(SYNFeedVideoCell *)cell;
- (void)videoCellSharePressed:(SYNFeedVideoCell *)cell;

@end

@interface SYNFeedVideoCell : UICollectionViewCell <SYNVideoInfoCell>

@property (nonatomic, strong) VideoInstance *videoInstance;

@property (nonatomic, strong, readonly) SYNVideoActionsBar *actionsBar;

@property (nonatomic, weak) id<SYNFeedVideoCellDelegate> delegate;

@end
