//
//  SYNCenteredFlowLayout.m
//  dolly
//
//  Created by Sherman Lo on 9/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCenteredFlowLayout.h"

@interface SYNCenteredFlowLayout ()

@property (nonatomic, assign) UIEdgeInsets centerInsets;

@end

@implementation SYNCenteredFlowLayout

- (CGSize)collectionViewContentSize {
	CGSize contentSize = [super collectionViewContentSize];
	
	return CGSizeMake(contentSize.width + self.centerInsets.left + self.centerInsets.right,
					  contentSize.height + self.centerInsets.top + self.centerInsets.bottom);
}

- (void)prepareLayout {
	[super prepareLayout];
	
	CGFloat insetWidth = (CGRectGetWidth(self.collectionView.bounds) - self.itemSize.width) / 2.0;
	self.centerInsets = UIEdgeInsetsMake(0, insetWidth, 0, insetWidth);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSMutableArray *layoutAttributes = [NSMutableArray array];
	for (UICollectionViewLayoutAttributes *attributes in [super layoutAttributesForElementsInRect:CGRectInset(rect, -self.centerInsets.left, -self.centerInsets.top)]) {
		[layoutAttributes addObject:[self centeredAttributesForAttributes:attributes]];
	}
	return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	return [self centeredAttributesForAttributes:[super layoutAttributesForItemAtIndexPath:indexPath]];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	return [self centeredAttributesForAttributes:[super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath]];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	return [self centeredAttributesForAttributes:[super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath]];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
	return [self centeredAttributesForAttributes:[super initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath]];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	return [self centeredAttributesForAttributes:[super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath]];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
	return [self centeredAttributesForAttributes:[super finalLayoutAttributesForDisappearingDecorationElementOfKind:elementKind atIndexPath:elementIndexPath]];
}

#pragma mark - Private

- (UICollectionViewLayoutAttributes *)centeredAttributesForAttributes:(UICollectionViewLayoutAttributes *)attributes {
	UICollectionViewLayoutAttributes *centeredAttributes = [attributes copy];
	centeredAttributes.center = CGPointMake(centeredAttributes.center.x + self.centerInsets.left,
											centeredAttributes.center.y + self.centerInsets.top);
	return centeredAttributes;
}

@end
