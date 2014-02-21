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
@property (nonatomic, strong) NSArray *loadedItems;
@property (nonatomic, assign) NSInteger totalItemCount;

- (instancetype)initWithItems:(NSArray *)items totalItemCount:(NSInteger)totalItemCount;

- (void)handleDataUpdatedForRange:(NSRange)range;
- (void)handleError;

- (void)loadItemsForRange:(NSRange)range;

- (void)resetWithItems:(NSArray *)items totalItemCount:(NSInteger)totalItemCount;

@end
