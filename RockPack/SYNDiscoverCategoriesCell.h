//
//  SYNCategoryCollectionViewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 16/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
#import "SubGenre.h"
@import UIKit;

@interface SYNDiscoverCategoriesCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, strong) SubGenre *subgenre;

@end
