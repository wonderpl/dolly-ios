//
//  SYNAddToChannelFlowLayout.m
//  dolly
//
//  Created by Michael Michailidis on 11/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAddToChannelExpandedFlowLayout.h"


@implementation SYNAddToChannelExpandedFlowLayout




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



-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
