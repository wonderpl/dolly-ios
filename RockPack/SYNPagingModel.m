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

@property (nonatomic, strong) NSArray *loadedItems;
@property (nonatomic, assign) NSInteger totalItemCount;
@property (nonatomic, assign) NSRange loadedRange;

@property (nonatomic, strong) NSMutableArray *completionBlocks;

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
		
		self.completionBlocks = [NSMutableArray array];
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

- (void)reloadInitialPage {
	[self reloadInitialPageWithCompletionHandler:nil];
}

- (void)reloadInitialPageWithCompletionHandler:(SYNPagingModelCompletionBlock)completion {
	self.loadedRange = NSMakeRange(NSNotFound, 0);
	
	[self loadNextPageWithCompletionHandler:completion];
}

- (void)loadNextPage {
	[self loadNextPageWithCompletionHandler:nil];
}

- (void)loadNextPageWithCompletionHandler:(SYNPagingModelCompletionBlock)completion {
	if (self.loading) {
		if (completion) {
			[self.completionBlocks addObject:[completion copy]];
		}
		
		return;
	}
	
	self.loading = YES;
	
	NSUInteger nextPageLocation = (self.loadedRange.location == NSNotFound ? 0 : NSMaxRange(self.loadedRange));
	NSRange range = NSMakeRange(nextPageLocation, self.batchSize);
	
	[self loadItemsForRange:range successBlock:^(NSArray *results, NSInteger totalItemCount) {
		BOOL hasChanged = ![results isEqualToArray:self.loadedItems];
		
		self.loadedItems = results;
		self.loadedRange = range;
		self.totalItemCount = totalItemCount;
		
		self.loading = NO;
		
		for (SYNPagingModelCompletionBlock completion in self.completionBlocks) {
			completion(YES, hasChanged);
		}
		self.completionBlocks = [NSMutableArray array];
		if (completion) {
			completion(YES, hasChanged);
		}
		
		[self.delegate pagingModelDataUpdated:self];
	} errorBlock:^{
		self.loading = NO;
		
		for (SYNPagingModelCompletionBlock completion in self.completionBlocks) {
			completion(NO, NO);
		}
		self.completionBlocks = [NSMutableArray array];
		if (completion) {
			completion(NO, NO);
		}
		
		[self.delegate pagingModelErrorOccurred:self];
	}];
}

#pragma mark - Protected

- (void)loadItemsForRange:(NSRange)range
			 successBlock:(SYNPagingModelResultsBlock)successBlock
			   errorBlock:(SYNPagingModelErrorBlock)errorBlock {
	
}

- (void)resetWithItems:(NSArray *)items totalItemCount:(NSInteger)totalItemCount {
	self.loadedItems = items;
	self.loadedRange = (items ? NSMakeRange(0, [items count]) : NSMakeRange(NSNotFound, 0));
	self.totalItemCount = totalItemCount;
}

@end
