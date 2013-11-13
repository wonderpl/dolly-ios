//
//  SYNAggregateFlowLayout.m
//  dolly
//
//  Created by Nick Banks on 28/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateFlowLayout.h"

@implementation SYNAggregateFlowLayout

- (BOOL) shouldInvalidateLayoutForBoundsChange: (CGRect) oldBounds
{
    return YES;
}


- (void) prepareLayout
{
    [super prepareLayout];
    
    // TODO: Find a way not to hardcode these 'magic numbers'
    self.minimumLineSpacing = 20;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGFloat horizontalCenter = (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(0.0, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    CGFloat xInset = 0;
    
    NSArray *array = [super layoutAttributesForElementsInRect: targetRect];
    
    if (array.count > 0)
    {
        UICollectionViewLayoutAttributes *layoutAttributes = array[0];
        CGFloat itemWidth = layoutAttributes.size.width;
        xInset = (int) horizontalCenter - (itemWidth / 2);
    }
    
    self.sectionInset =  UIEdgeInsetsMake (0.0f, xInset, 0.0f, xInset);
}


- (CGPoint) targetContentOffsetForProposedContentOffset: (CGPoint) proposedContentOffset
                                  withScrollingVelocity: (CGPoint) velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *array = [super layoutAttributesForElementsInRect: targetRect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array)
    {
        CGFloat itemHoizontalCenter = layoutAttributes.center.x;
        
        if (ABS(itemHoizontalCenter - horizontalCenter) < ABS(offsetAdjustment))
        {
            offsetAdjustment = itemHoizontalCenter - horizontalCenter;
            
        }
    }
    
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}


@end
