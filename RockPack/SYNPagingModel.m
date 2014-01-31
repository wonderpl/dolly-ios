//
//  SYNPagingModel.m
//  dolly
//
//  Created by Sherman Lo on 3/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNPagingModel.h"
#import "SYNPagingModel+Protected.h"

static const NSInteger DefaultBatchSize = 40;

@interface SYNPagingModel ()

@property (nonatomic, assign) NSRange loadedRange;

@end

@implementation SYNPagingModel

#pragma mark - Init / Dealloc

- (instancetype)init {
	return [self initWithLoadedRange:NSMakeRange(NSNotFound, 0)];
}

- (instancetype)initWithLoadedRange:(NSRange)range {
	if (self = [super init]) {
		self.loadedRange = range;
	}
	return self;
}

#pragma mark - Public

- (BOOL)hasMoreItems {
	return (self.loadedRange.location == NSNotFound || (NSMaxRange(self.loadedRange) < self.totalItemCount));
}

- (NSInteger)itemCount {
	return [self.loadedItems count];
}

- (id)itemAtIndex:(NSInteger)index {
	return self.loadedItems[index];
}

- (NSInteger)batchSize {
	return DefaultBatchSize;
}

- (void)reset {
	self.totalItemCount = 0;
	
	self.loadedRange = NSMakeRange(NSNotFound, 0);
}

- (void)loadNextPage {
	if (self.loading) {
		return;
	}
	
	self.loading = YES;
	
	NSUInteger nextPageLocation = (self.loadedRange.location == NSNotFound ? 0 : NSMaxRange(self.loadedRange));
	[self loadItemsForRange:NSMakeRange(nextPageLocation, self.batchSize)];
}

#pragma mark - Protected

- (void)handleDataUpdatedForRange:(NSRange)range {
	self.loading = NO;
	self.loadedRange = range;
	
	[self.delegate pagingModelDataUpdated:self];
}

- (void)handleError {
	self.loading = NO;
	
	[self.delegate pagingModelErrorOccurred:self];
}

- (void)loadItemsForRange:(NSRange)range {
	
}

@end
