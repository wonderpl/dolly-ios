//
//  SYNPagingModel.h
//  dolly
//
//  Created by Sherman Lo on 3/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYNPagingModel;

@protocol SYNPagingModelDelegate

- (void)pagingModelDataUpdated:(SYNPagingModel *)pagingModel;
- (void)pagingModelErrorOccurred:(SYNPagingModel *)pagingModel;

@end

typedef void (^SYNPagingModelCompletionBlock)(BOOL success, BOOL hasChanged);

@interface SYNPagingModel : NSObject

@property (nonatomic, assign, readonly) NSRange loadedRange;

@property (nonatomic, assign, readonly) NSInteger itemCount;
@property (nonatomic, assign, readonly) NSInteger totalItemCount;

@property (nonatomic, weak) id<SYNPagingModelDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL hasMoreItems;

- (id)itemAtIndex:(NSInteger)index;

- (void)reloadInitialPage;
- (void)reloadInitialPageWithCompletionHandler:(SYNPagingModelCompletionBlock)completion;

- (void)loadNextPage;
- (void)loadNextPageWithCompletionHandler:(SYNPagingModelCompletionBlock)completion;

- (void)reset;

@end
