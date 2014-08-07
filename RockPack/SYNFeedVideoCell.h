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

- (void)videoCell:(SYNFeedVideoCell *)cell favouritePressed:(UIButton *)button;
- (void)videoCell:(SYNFeedVideoCell *)cell addToChannelPressed:(UIButton *)button;
- (void)videoCell:(SYNFeedVideoCell *)cell sharePressed:(UIButton *)button;
- (void)videoCell:(SYNFeedVideoCell *)cell addedByPressed:(UIButton *)button;

@optional
- (void)clickToMore:(UIButton *)button withURL:(NSURL *)url;

@end

@interface SYNFeedVideoCell : UICollectionViewCell <SYNVideoInfoCell>

@property (nonatomic, strong) VideoInstance *videoInstance;

@property (nonatomic, strong, readonly) SYNVideoActionsBar *actionsBar;

@property (nonatomic, weak) id<SYNFeedVideoCellDelegate> delegate;

- (void)setDarkView;
- (void)setLightView;

@end
