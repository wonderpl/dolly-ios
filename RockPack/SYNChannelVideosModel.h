//
//  SYNChannelVideosModel.h
//  dolly
//
//  Created by Sherman Lo on 9/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNPagingModel.h"

@class Channel;

@interface SYNChannelVideosModel : SYNPagingModel

+ (instancetype)modelWithChannel:(Channel *)channel;

@end
