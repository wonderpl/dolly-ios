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

//Currently loaded items.
@property (nonatomic, assign, readonly) NSInteger itemCount;

//Total item count taken from the backend data
@property (nonatomic, assign, readonly) NSInteger totalItemCount;

@property (nonatomic, weak) id<SYNPagingModelDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL hasMoreItems;

- (id)itemAtIndex:(NSInteger)index;

// ReloadInitial page was required as there were situations where new data had come into the backend but the app wouldn't update as
// the new data was in a position already fetched and the paging model only loads the next page.
- (void)reloadInitialPage;
- (void)reloadInitialPageWithCompletionHandler:(SYNPagingModelCompletionBlock)completion;

- (void)loadNextPage;
- (void)loadNextPageWithCompletionHandler:(SYNPagingModelCompletionBlock)completion;

- (void)reset;

@end
