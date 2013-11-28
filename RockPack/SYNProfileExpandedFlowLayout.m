//
//  SYNProfileExpandedFlowLayout.m
//  dolly
//
//  Created by Cong on 28/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNProfileExpandedFlowLayout.h"
#import "SYNDeviceManager.h"
@implementation SYNProfileExpandedFlowLayout


-(id)init {
    if (!(self = [super init])) return nil;
    
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.itemSize = CGSizeMake(320, 71);
    self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

    self.headerReferenceSize = CGSizeMake(320, 472);
    return self;
}


-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesArray = [super layoutAttributesForElementsInRect:rect];
    
    
    
    for (UICollectionViewLayoutAttributes *attributes in attributesArray)
    {
        CGRect cellFrame = attributes.frame;
        if(attributes.indexPath.item == 0)
        {
            cellFrame.size.height += 94.0f;
        }
//        else if ((IS_IPAD && (attributes.indexPath.item % 2 == 0)) || IS_IPHONE) // odd cells (0 indexed)
//        {
////            cellFrame.origin.y += kChannelCellExpandedHeight - kChannelCellDefaultHeight;
//        }
        else if(IS_IPHONE)
        {
            cellFrame.origin.y+= 94.0f;
            
        }
        else if (IS_IPAD)
        {
            if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation])) {
                if (attributes.indexPath.item%2 == 0) {
                    cellFrame.origin.y +=94.0f;
                }
            }
            else
            {
                if (attributes.indexPath.item%3 == 0) {
                    cellFrame.origin.y +=94.0f;
                }
                
            }

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
