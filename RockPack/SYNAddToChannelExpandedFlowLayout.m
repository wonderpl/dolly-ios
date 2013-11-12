//
//  SYNAddToChannelFlowLayout.m
//  dolly
//
//  Created by Michael Michailidis on 11/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAddToChannelExpandedFlowLayout.h"


@implementation SYNAddToChannelExpandedFlowLayout



- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
}
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesArray = [super layoutAttributesForElementsInRect:rect];
    
    
    
    for (UICollectionViewLayoutAttributes *attributes in attributesArray)
    {
        CGRect cellFrame = attributes.frame;
        if(attributes.indexPath.item == 0)
        {
            
            cellFrame.size.height = kChannelCellExpandedHeight;
            
        }
        else if ((IS_IPAD && (attributes.indexPath.item % 2 == 0)) || IS_IPHONE) // odd cells (0 indexed)
        {
            cellFrame.origin.y += kChannelCellExpandedHeight - kChannelCellDefaultHeight;
        }
        attributes.frame = cellFrame;
    }
    
    
    
    return attributesArray;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    //[self applyLayoutAttributes:attributes];
    
    return attributes;
}



@end
