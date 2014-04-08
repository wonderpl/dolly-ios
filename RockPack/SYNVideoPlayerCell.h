//
//  SYNVideoPlayerCell.h
//  dolly
//
//  Created by Sherman Lo on 1/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoInstance;
@class SYNVideoPlayer;

@interface SYNVideoPlayerCell : UICollectionViewCell

@property (nonatomic, strong) SYNVideoPlayer *videoPlayer;

- (void)cellDisplayEnded;

@end
