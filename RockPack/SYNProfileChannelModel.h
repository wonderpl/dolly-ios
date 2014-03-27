//
//  SYNProfileModel.h
//  dolly
//
//  Created by Cong Le on 17/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNPagingModel.h"

@class ChannelOwner;
@class Channel;


@interface SYNProfileChannelModel : SYNPagingModel

+ (instancetype)modelWithChannelOwner:(ChannelOwner *)channelOwner;

@end
