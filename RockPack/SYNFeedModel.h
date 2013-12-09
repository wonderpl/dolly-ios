//
//  SYNFeedModel.h
//  dolly
//
//  Created by Sherman Lo on 4/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNPagingModel.h"

@class Channel;
@class FeedItem;

typedef NS_ENUM(NSInteger, SYNFeedModelMode) {
	SYNFeedModelModeFeed,
	SYNFeedModelModeVideo
};

@interface SYNFeedModel : SYNPagingModel

@property (nonatomic, assign) SYNFeedModelMode mode;

- (Channel *)channelForFeedItem:(FeedItem *)feedItem;

- (NSArray *)videoInstancesForFeedItem:(FeedItem *)feedItem;
- (NSArray *)channelsForFeedItem:(FeedItem *)feedItem;

- (NSInteger)videoIndexForIndexPath:(NSIndexPath *)indexPath;

@end
