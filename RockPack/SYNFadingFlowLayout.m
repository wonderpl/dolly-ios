//
//  SYNFadingFlowLayout.m
//  dolly
//
//  Created by Nick Banks on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFadingFlowLayout.h"

#define ITEM_SIZE		50.0
#define ACTIVE_DISTANCE 25.0
#define FADE_DISTANCE 200.0f


@implementation SYNFadingFlowLayout

- (BOOL) shouldInvalidateLayoutForBoundsChange: (CGRect) oldBounds
{
    return YES;
}


- (NSArray *) layoutAttributesForElementsInRect: (CGRect) rect
{
    NSArray *array = [super layoutAttributesForElementsInRect: rect];
    CGRect visibleRect;
    
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes *attributes in array)
    {
        if (CGRectIntersectsRect(attributes.frame, rect))
        {
            CGFloat distance = CGRectGetMidY(visibleRect) - attributes.center.y;
            CGFloat normalizedDistance = ABS(distance);
            
            if (normalizedDistance < ACTIVE_DISTANCE)
            {
                attributes.alpha = 1.0f;
            }
            else
            {
                CGFloat fadeDistance = ((normalizedDistance - ACTIVE_DISTANCE) / FADE_DISTANCE) * 0.9;
                attributes.alpha = 1 - fadeDistance ;
            }
        }
    }
    
    return array;
}


- (CGPoint) targetContentOffsetForProposedContentOffset: (CGPoint) proposedContentOffset
                                  withScrollingVelocity: (CGPoint) velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat verticalCenter = proposedContentOffset.y + (CGRectGetHeight(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(0.0, proposedContentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *array = [super layoutAttributesForElementsInRect: targetRect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array)
    {
        CGFloat itemVerticalCenter = layoutAttributes.center.y;
        
        if (ABS(itemVerticalCenter - verticalCenter) < ABS(offsetAdjustment))
        {
            offsetAdjustment = itemVerticalCenter - verticalCenter;
        }
    }
    
    return CGPointMake(proposedContentOffset.x, proposedContentOffset.y + offsetAdjustment);
}


@end
