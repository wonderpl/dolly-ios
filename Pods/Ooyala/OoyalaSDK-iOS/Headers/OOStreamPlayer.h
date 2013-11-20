//
//  OOStreamPlayer.h
//  OoyalaSDK
//
//  Created by Chris Leonavicius on 11/12/12.
//  Copyright (c) 2012 Ooyala, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OOPlayer.h"
#import "OOPlayerInfo.h"

@interface OOStreamPlayer : OOPlayer
@property OOSeekStyle seekStyle;
+ (id<OOPlayerInfo>) defaultPlayerInfo;
+ (void) setDefaultPlayerInfo:(id<OOPlayerInfo>) playerInfo;

- (BOOL)setup:(NSArray *)streams;
- (id<OOPlayerInfo>)playerInfo;
@end
