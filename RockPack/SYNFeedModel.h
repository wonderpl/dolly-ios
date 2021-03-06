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

@interface SYNFeedModel : SYNPagingModel

+ (instancetype)sharedModel;

- (FeedItem *)feedItemAtindex:(NSInteger)index;
- (id)resourceForFeedItem:(FeedItem *)feedItem;
- (NSInteger)feedItemCount;

- (NSInteger)itemIndexForFeedIndex:(NSInteger)feedIndex;
- (NSInteger)videoIndexForFeedIndex:(NSInteger)feedIndex;

@end
