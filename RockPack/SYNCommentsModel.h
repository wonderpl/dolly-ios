//
//  SYNCommentsModel.h
//  dolly
//
//  Created by Sherman Lo on 31/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNPagingModel.h"

@class VideoInstance;

@interface SYNCommentsModel : SYNPagingModel

+ (instancetype)modelWithVideoInstance:(VideoInstance *)videoInstance;

- (void)removeObjectAtIndex:(NSInteger)index;
- (void)loadNewComments;
- (void)resetLoadedData;

@end
