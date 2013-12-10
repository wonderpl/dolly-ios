//
//  SYNPagingModel+Protected.h
//  dolly
//
//  Created by Sherman Lo on 5/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNPagingModel.h"

@interface SYNPagingModel ()

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) NSRange loadedRange;
@property (nonatomic, strong) NSArray *loadedItems;
@property (nonatomic, assign) NSInteger totalItemCount;

- (void)handleDataUpdated;
- (void)handleError;

- (void)loadItemsForRange:(NSRange)range;

@end
