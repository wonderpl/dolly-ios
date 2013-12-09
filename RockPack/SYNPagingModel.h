//
//  SYNPagingModel.h
//  dolly
//
//  Created by Sherman Lo on 3/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYNPagingModelDelegate <UICollectionViewDataSource>

- (void)pagingModelDataUpdated;
- (void)pagingModelErrorOccurred;

@end

@interface SYNPagingModel : NSObject

@property (nonatomic, assign, readonly) NSInteger batchSize;
@property (nonatomic, assign, readonly) NSRange loadedRange;

@property (nonatomic, assign, readonly) NSInteger itemCount;
@property (nonatomic, assign, readonly) NSInteger totalItemCount;

@property (nonatomic, weak) id<SYNPagingModelDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL hasMoreItems;

- (id)itemAtIndex:(NSInteger)index;

- (void)loadNextPage;

- (void)reset;

@end
