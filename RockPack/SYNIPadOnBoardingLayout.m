//
//  SYNIPadOnBoardingLayout.m
//  dolly
//
//  Created by Sherman Lo on 15/05/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNIPadOnBoardingLayout.h"
#import "NSArray+Helpers.h"

@interface SYNIPadOnBoardingLayout ()

@property (nonatomic, copy) NSArray *layoutAttributes;

@end

@implementation SYNIPadOnBoardingLayout

#pragma mark - UICollectionViewLayout

- (void)prepareLayout {
	NSMutableArray *layoutAttributes = [NSMutableArray array];
	
	CGFloat currentY = 0.0;
	
	for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
		
		NSMutableArray *sectionLayoutAttributes = [NSMutableArray array];
		
		CGSize headerSize = [self headerSizeForSection:section];
		
		if (headerSize.height) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
			UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
																													 withIndexPath:indexPath];
			
			attrs.frame = CGRectMake(0, currentY, CGRectGetWidth(self.collectionView.bounds), headerSize.height);
			
			currentY += headerSize.height;
			
			[sectionLayoutAttributes addObject:attrs];
		}
		
		NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
		
		BOOL isLandscape = CGRectGetWidth(self.collectionView.bounds) > CGRectGetHeight(self.collectionView.bounds);
		NSInteger columnCount = (isLandscape ? 4 : 3);
		
		NSInteger item = 0;
		NSArray *rowLayout = [self rowLayoutForItemCount:numberOfItems columnCount:columnCount];
		for (NSInteger row = 0; row < [rowLayout count]; row++) {
			NSInteger rowItemCount = [rowLayout[row] integerValue];
			
			CGFloat cellWidth = (rowItemCount * self.itemSize.width) + ((rowItemCount - 1) * self.minimumInteritemSpacing);
			CGFloat startX = (CGRectGetWidth(self.collectionView.bounds) - cellWidth) / 2.0;
			
			for (NSInteger rowItem = 0; rowItem < rowItemCount; rowItem++) {
				NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
				UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
				
				attrs.frame = CGRectMake(startX + rowItem * (self.itemSize.width + self.minimumInteritemSpacing),
										 currentY,
										 self.itemSize.width,
										 self.itemSize.height);
				
				[sectionLayoutAttributes addObject:attrs];
				
				item++;
			}
			
			currentY += self.itemSize.height + self.minimumLineSpacing;
		}
		
		CGSize footerSize = [self footerSizeForSection:section];
		
		if (footerSize.height) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
			UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
																													 withIndexPath:indexPath];
			
			attrs.frame = CGRectMake(0, currentY, CGRectGetWidth(self.collectionView.bounds), footerSize.height);
			
			currentY += footerSize.height;
			
			[sectionLayoutAttributes addObject:attrs];
		}
		
		[layoutAttributes addObject:sectionLayoutAttributes];
	}
	
	self.layoutAttributes = layoutAttributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *attrs, NSDictionary *bindings) {
		return CGRectIntersectsRect(rect, attrs.frame);
	}];
	
	return [[self.layoutAttributes flattenedArray] filteredArrayUsingPredicate:predicate];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	return self.layoutAttributes[indexPath.section][indexPath.item];
}

#pragma mark - Private

- (NSArray *)rowLayoutForItemCount:(NSInteger)itemCount columnCount:(NSInteger)columnCount {
	NSInteger rowCount = ceil(itemCount / (CGFloat)columnCount);
	BOOL hasDanglingItem = ((itemCount > 1) && ((itemCount % columnCount) == 1));
	
	NSInteger remainingItems = itemCount;
	
	NSMutableArray *rowLayout = [NSMutableArray array];
	for (NSInteger row = 0; row < rowCount; row++) {
		BOOL secondLastRow = ((rowCount - 2) == row);
		
		// If there's a dangling item on the last row we want the second last row to have one less item
		NSInteger maxNumberOfItemsInRow = (hasDanglingItem && secondLastRow ? columnCount - 1 : columnCount);
		NSInteger numberOfItemsInRow = MIN(remainingItems, maxNumberOfItemsInRow);
		
		[rowLayout addObject:@(numberOfItemsInRow)];
		remainingItems -= numberOfItemsInRow;
	}
	return rowLayout;
}

- (CGSize)headerSizeForSection:(NSInteger)section {
	id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
		return [delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
	}
	return self.headerReferenceSize;
}

- (CGSize)footerSizeForSection:(NSInteger)section {
	id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
		return [delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section];
	}
	return self.footerReferenceSize;
}

@end
