//
//  SYNVideoViewerThumbnailLayout.h
//  rockpack
//
//  Created by Nick Banks on 01/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@interface SYNVideoViewerThumbnailLayout : UICollectionViewFlowLayout

@property (strong, nonatomic, strong) NSIndexPath *selectedItemIndexPath;

- (UICollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath;

@end
