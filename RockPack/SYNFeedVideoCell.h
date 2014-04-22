//
//  SYNFeedVideoCell.h
//  dolly
//
//  Created by Sherman Lo on 15/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoInstance;
@class SYNVideoActionsBar;
@class SYNFeedVideoCell;

@protocol SYNFeedVideoCellDelegate <NSObject>

- (void)videoCellFavouritePressed:(SYNFeedVideoCell *)cell;
- (void)videoCellAddToChannelPressed:(SYNFeedVideoCell *)cell;
- (void)videoCellSharePressed:(SYNFeedVideoCell *)cell;
- (void)videoCellAvatarPressed:(SYNFeedVideoCell *)cell;

@end

@interface SYNFeedVideoCell : UICollectionViewCell

@property (nonatomic, strong) VideoInstance *videoInstance;

@property (nonatomic, strong, readonly) SYNVideoActionsBar *actionsBar;

@property (nonatomic, weak) id<SYNFeedVideoCellDelegate> delegate;

@end
