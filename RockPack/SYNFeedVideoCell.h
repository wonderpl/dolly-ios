//
//  SYNFeedVideoCell.h
//  dolly
//
//  Created by Sherman Lo on 15/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNVideoInfoCell.h"
#import "SYNVideoPlayerCell.h"
#import "SYNVideoPlayer.h"

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
- (void)videoCell:(SYNFeedVideoCell *)cell maximiseVideoPlayer:(UIButton *)button;

@end

@interface SYNFeedVideoCell : UICollectionViewCell <SYNVideoInfoCell>

@property (nonatomic, strong) VideoInstance *videoInstance;

@property (nonatomic, strong, readonly) SYNVideoActionsBar *actionsBar;

@property (strong, nonatomic) IBOutlet SYNVideoPlayerCell *videoPlayerCell;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, weak) id<SYNFeedVideoCellDelegate> delegate;

@end
