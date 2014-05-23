//
//  SYNIPadFeedLayout.m
//  dolly
//
//  Created by Sherman Lo on 23/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNIPadFeedLayout.h"
#import "SYNPagingModel.h"

static const CGSize PortraitLargeCellSize = { .width = 672.0, .height = 596.0};
static const CGSize PortraitSmallCellSize = { .width = 336.0, .height = 380.0};

static const CGSize LandscapeLargeCellSize = { .width = 578.0, .height = 704.0};
static const CGSize LandscapeSmallCellSize = { .width = 350.0, .height = 352.0};

@interface SYNIPadFeedLayout ()

@property (nonatomic, assign) BOOL isPortrait;

@property (nonatomic, assign) CGFloat footerTop;

@end

@implementation SYNIPadFeedLayout

- (void)prepareLayout {
	self.isPortrait = (CGRectGetWidth(self.collectionView.bounds) < CGRectGetHeight(self.collectionView.bounds));
	
	NSInteger numberOfCells = [self.collectionView numberOfItemsInSection:0];
	
	NSInteger numberOfFullBlocks = (numberOfCells / 3);
	
	NSInteger numberOfCellsInFinalBlock = (numberOfCells % 3);
	BOOL isFinalBlockEven = (numberOfFullBlocks % 2 == 0);
	
	if (self.isPortrait) {
		CGFloat finalBlockHeight = 0.0;
		if (numberOfCellsInFinalBlock == 1) {
			finalBlockHeight = PortraitLargeCellSize.height;
		} else if (numberOfCellsInFinalBlock == 2) {
			finalBlockHeight = PortraitLargeCellSize.height + PortraitSmallCellSize.height;
		}
		CGFloat fullBlockHeight = (PortraitLargeCellSize.height + PortraitSmallCellSize.height) * numberOfFullBlocks;
		
		self.footerTop = fullBlockHeight + finalBlockHeight;
	} else {
		CGFloat finalBlockHeight = 0.0;
		if (numberOfCellsInFinalBlock == 1) {
			finalBlockHeight = (isFinalBlockEven ? LandscapeLargeCellSize.height : LandscapeSmallCellSize.height);
		} else if (numberOfCellsInFinalBlock == 2) {
			finalBlockHeight = LandscapeLargeCellSize.height;
		}
		CGFloat fullBlockHeight = LandscapeLargeCellSize.height * numberOfFullBlocks;
		
		self.footerTop = fullBlockHeight + finalBlockHeight;
	}
}

- (CGSize)collectionViewContentSize {
	CGFloat footerHeight = ([self.model hasMoreItems] ? 50.0 : 0.0);
	
	return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), self.footerTop + footerHeight);
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
	CGFloat blockPosition = self.collectionView.bounds.size.height * self.blockLocation;
	return CGPointMake(0, blockPosition - self.collectionView.contentInset.top);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSInteger numberOfCells = [self.collectionView numberOfItemsInSection:0];
	
	NSMutableArray *attributes = [NSMutableArray array];
	for (NSInteger i = 0; i < numberOfCells; i++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
		
		UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
		
		attrs.frame = [self frameForCellAtIndexPath:indexPath];
		
		if (CGRectIntersectsRect(rect, attrs.frame)) {
			[attributes addObject:attrs];
		}
	}
	if ([self.model hasMoreItems]) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
		UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
																												 withIndexPath:indexPath];
		attrs.frame = CGRectMake(0, self.footerTop, CGRectGetWidth(self.collectionView.bounds), 50.0);
		
		[attributes addObject:attrs];
	}
	
	return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	
	attrs.frame = [self frameForCellAtIndexPath:indexPath];
	
	return attrs;
}

- (CGRect)frameForCellAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger blockNumber = (indexPath.item / 3);
	NSInteger blockOffset = (indexPath.item % 3);
	
	if (self.isPortrait) {
		NSInteger heightOffset = (blockOffset - 1);
		BOOL isLargeCell = (blockOffset == 0);
		
		if (isLargeCell) {
			return CGRectMake(0,
							  blockNumber * (PortraitLargeCellSize.height + PortraitSmallCellSize.height),
							  PortraitLargeCellSize.width,
							  PortraitLargeCellSize.height);
		} else {
			return CGRectMake(heightOffset * PortraitSmallCellSize.width,
							  blockNumber * (PortraitLargeCellSize.height + PortraitSmallCellSize.height) + PortraitLargeCellSize.height,
							  PortraitSmallCellSize.width,
							  PortraitSmallCellSize.height);
		}
	} else {
		BOOL isEvenBlock = (blockNumber % 2 == 0);
		BOOL isLargeCell = (isEvenBlock ? (blockOffset == 0) : (blockOffset == 2));
		
		NSInteger heightOffset = (isEvenBlock ? blockOffset - 1 : blockOffset);
		
		if (isLargeCell) {
			return CGRectMake((isEvenBlock ? 0 : LandscapeSmallCellSize.width),
							  blockNumber * (LandscapeLargeCellSize.height),
							  LandscapeLargeCellSize.width,
							  LandscapeLargeCellSize.height);
		} else {
			return CGRectMake((isEvenBlock ? LandscapeLargeCellSize.width : 0),
							  blockNumber * LandscapeLargeCellSize.height + (heightOffset * LandscapeSmallCellSize.height),
							  LandscapeSmallCellSize.width,
							  LandscapeSmallCellSize.height);
		}
	}
}

@end
