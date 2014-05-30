//
//  SYNProfileVideoModel.h
//  dolly
//
//  Created by Cong on 30/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNPagingModel.h"

@class ChannelOwner;

@interface SYNProfileVideoModel : SYNPagingModel

+ (instancetype)modelWithChannelOwner:(ChannelOwner *)channelOwner;

@end
