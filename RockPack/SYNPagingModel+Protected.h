//
//  SYNPagingModel+Protected.h
//  dolly
//
//  Created by Sherman Lo on 5/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNPagingModel.h"

typedef void (^SYNPagingModelResultsBlock)(NSArray *results, NSInteger totalItemCount);
typedef void (^SYNPagingModelErrorBlock)();

@interface SYNPagingModel ()

@property (nonatomic, assign) BOOL loading;

- (instancetype)initWithItems:(NSArray *)items totalItemCount:(NSInteger)totalItemCount;

- (void)loadItemsForRange:(NSRange)range
			 successBlock:(SYNPagingModelResultsBlock)successBlock
			   errorBlock:(SYNPagingModelErrorBlock)errorBlock;

- (void)resetWithItems:(NSArray *)items totalItemCount:(NSInteger)totalItemCount;

@end
