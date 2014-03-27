//
//  SYNIPadCreateChannelLayout.m
//  dolly
//
//  Created by Cong Le on 17/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNIPadCreateChannelLayout.h"
#import "SYNDeviceManager.h"
@implementation SYNIPadCreateChannelLayout

-(id)init {
	if (self = [super init]) {
		self.sectionInset = UIEdgeInsetsMake(0, 47, 700, 47);
		self.minimumInteritemSpacing = 0.0f;
		self.minimumLineSpacing = 14.0f;
		self.itemSize = CGSizeMake(280, 80);
	}
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
		cellFrame.size.height = 280;
		
	}
	else if (attributes.indexPath.item == 0 && attributes.representedElementKind){
		
	}
	else if (UIDeviceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation])) {
		if (attributes.indexPath.item %2 == 0) {
			cellFrame.origin.y +=94.0f;
		}
	} else if (UIDeviceOrientationIsLandscape([[SYNDeviceManager sharedInstance] orientation])) {
		if (attributes.indexPath.item%3 == 0) {
			cellFrame.origin.y +=94.0f;
		}
	}

	return cellFrame;
}



-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


@end
