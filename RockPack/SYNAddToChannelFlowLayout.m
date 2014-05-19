//
//  SYNAddToChannelFlowLayout.m
//  dolly
//
//  Created by Michael Michailidis on 11/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAddToChannelFlowLayout.h"

@implementation SYNAddToChannelFlowLayout

-(id)init
{
    if (!(self = [super init]))
        return nil;
    
    self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.minimumInteritemSpacing = 0.0f;
    self.minimumLineSpacing = IS_IPAD ? 10.0f : 0.0f;
    self.itemSize = CGSizeMake(320.0f, kChannelCellDefaultHeight );
    self.headerReferenceSize = CGSizeZero;
    
    
    return self;
}


-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes =
    [super layoutAttributesForItemAtIndexPath:indexPath];
    
	attributes.frame = [self frameForItem :attributes];
    
	return attributes;
}


-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesArray = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *attributes in attributesArray)
    {
        attributes.frame = [self frameForItem :attributes];
    }
    return attributesArray;
}

- (CGRect) frameForItem: (UICollectionViewLayoutAttributes*) attributes {
	CGRect cellFrame = attributes.frame;
    
	if (attributes.indexPath.item == 0 && !attributes.representedElementKind) {
        if (IS_IPHONE) {
            cellFrame.size.height = 60;
        }
	} else {
        if (IS_IPHONE) {
            cellFrame.origin.y -= 31;
        }
    }
    
	return cellFrame;
}



@end
