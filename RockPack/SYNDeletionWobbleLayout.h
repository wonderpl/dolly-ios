//
//  SYNDeletionWobbleLayout.h
//  rockpack
//
//  Created by Nick Banks on 01/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNIntegralCollectionViewFlowLayout.h"
@import UIKit;

@protocol SYNDeletionWobbleLayoutDelegate <UICollectionViewDelegateFlowLayout>

@required

- (BOOL) isDeletionModeActiveForCollectionView: (UICollectionView *) collectionView
                                        layout: (UICollectionViewLayout*) collectionViewLayout;

@end

@interface SYNDeletionWobbleLayout : SYNIntegralCollectionViewFlowLayout

+ (SYNDeletionWobbleLayout*) layoutWithItemSize: (CGSize) itemSize
                        minimumInterItemSpacing: (CGFloat) minSpace
                             minimumLineSpacing: (CGFloat) lineSpace
                                scrollDirection: (UICollectionViewScrollDirection) scrollDirection
                                   sectionInset: (UIEdgeInsets) insets;

@end
