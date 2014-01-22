//
//  SYNFadingFlowLayout.m
//  dolly
//
//  Created by Nick Banks on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFadingFlowLayout.h"
#import <math.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

#define ACTIVE_DISTANCE 25.0
#define FADE_DISTANCE 200.0f


@implementation SYNFadingFlowLayout

- (BOOL) shouldInvalidateLayoutForBoundsChange: (CGRect) oldBounds
{
    return YES;
}

- (void) prepareLayout
{
    [super prepareLayout];
    
    // TODO: Find a way not to hardcode these
    self.itemSize = CGSizeMake (320, (IS_IPAD ? 40.0f : 40.0f));
    
    if (!IS_IPHONE_5) {
        self.itemSize = CGSizeMake(320, 30);
    }
    
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    CGFloat verticalCenter = (CGRectGetHeight(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(0.0f,  0.0f, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *attributesArray = [super layoutAttributesForElementsInRect: targetRect];
    
    // If we have anything to layout
    if (attributesArray.count > 0)
    {
        UICollectionViewLayoutAttributes *firstLayoutAttribute = attributesArray[0];
        
        self.sectionInset =  UIEdgeInsetsMake (verticalCenter - (firstLayoutAttribute.size.height / 2), 0,
                                               verticalCenter - (firstLayoutAttribute.size.height / 2), 0);
    }
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
            
            CGFloat fadeDistance = ((normalizedDistance - ACTIVE_DISTANCE) / FADE_DISTANCE) * 1.8;
            
            
            //Radius of the centre of the circle on the Z axis
            long radius = 60;
            
            if (distance<0) {
                
                CATransform3D translateToMiddle = CATransform3DMakeTranslation(0, distance, 0);
                
                CATransform3D translateToOut = CATransform3DMakeTranslation(0, 0, -radius);
                
                CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
                rotationAndPerspectiveTransform.m34 = 1.0 / -2000;
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, atan(distance/radius), 1.0f, 0.0f, 0.0f);
                
                CATransform3D translateBackIn = CATransform3DMakeTranslation(0, 0, radius);
                
                CATransform3D translateToOriginal = CATransform3DMakeTranslation(0, -distance, 0);
                
                attributes.transform3D = CATransform3DConcat(attributes.transform3D, translateToOriginal);
                
                attributes.transform3D = CATransform3DConcat(attributes.transform3D, translateBackIn);
            
                attributes.transform3D = CATransform3DConcat(attributes.transform3D, rotationAndPerspectiveTransform);
                
                attributes.transform3D = CATransform3DConcat(attributes.transform3D, translateToOut);
                
                attributes.transform3D = CATransform3DConcat(attributes.transform3D, translateToMiddle);
                
            } else {
                // == Top half
                
                CATransform3D translateToMiddle = CATransform3DMakeTranslation(0, distance, 0);
                
                CATransform3D translateToOut = CATransform3DMakeTranslation(0, 0, -radius);
                
                CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
                rotationAndPerspectiveTransform.m34 = 1.0 / -2000;
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, atan(distance/radius), 1.0f, 0.0f, 0.0f);
                
                CATransform3D translateBackIn = CATransform3DMakeTranslation(0, 0, radius);

                CATransform3D translateToOriginal = CATransform3DMakeTranslation(0, -distance, 0);
                
                attributes.transform3D = CATransform3DConcat(attributes.transform3D, translateToOriginal);
                
                attributes.transform3D = CATransform3DConcat(attributes.transform3D, translateBackIn);
                
                attributes.transform3D = CATransform3DConcat(attributes.transform3D, rotationAndPerspectiveTransform);
                
                attributes.transform3D = CATransform3DConcat(attributes.transform3D, translateToOut);
                
                attributes.transform3D = CATransform3DConcat(attributes.transform3D, translateToMiddle);
            }
            attributes.alpha = 1 - fadeDistance;
            
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
