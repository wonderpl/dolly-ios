//
//  SYNSearchVideoLikesModel.h
//  dolly
//
//  Created by Sherman Lo on 13/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNPagingModel.h"

@interface SYNSearchVideoLikesModel : SYNPagingModel

+ (instancetype)modelWithVideoId:(NSString *)videoId;

@end
