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
	return [self initWithItems:nil totalItemCount:0];
}

- (instancetype)initWithItems:(NSArray *)items totalItemCount:(NSInteger)totalItemCount {
	if (self = [super init]) {
		self.loadedItems = items;
		self.loadedRange = (items ? NSMakeRange(0, [items count]) : NSMakeRange(NSNotFound, 0));
		self.totalItemCount = totalItemCount;
	}
	return self;
}

#pragma mark - Public

- (BOOL)hasMoreItems {
	return (self.loadedRange.location == NSNotFound || self.totalItemCount == NSNotFound || (NSMaxRange(self.loadedRange) < self.totalItemCount));
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
	[self resetWithItems:nil totalItemCount:0];
}

- (void)resetWithItems:(NSArray *)items totalItemCount:(NSInteger)totalItemCount {
	self.loadedItems = items;
	self.loadedRange = (items ? NSMakeRange(0, [items count]) : NSMakeRange(NSNotFound, 0));
	self.totalItemCount = totalItemCount;
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
