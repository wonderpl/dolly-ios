//
//  SYNVideoPlayerDismissIndex.h
//  dolly
//
//  Created by Cong on 30/06/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoPlayer.h"

@protocol SYNVideoPlayerDismissIndex <NSObject>

- (void)dismissPosition:(NSInteger)index;

@optional

- (void)dismissPosition:(NSInteger)index :(SYNVideoPlayer*)videoPlayer;

@end
