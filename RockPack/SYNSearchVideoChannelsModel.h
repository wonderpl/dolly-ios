//
//  SYNSearchVideoChannelsModel.h
//  dolly
//
//  Created by Sherman Lo on 17/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNPagingModel.h"

@interface SYNSearchVideoChannelsModel : SYNPagingModel

+ (instancetype)modelWithVideoId:(NSString *)videoId;

@end
