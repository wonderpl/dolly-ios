//
//  SYNCategoryCollectionViewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 16/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import UIKit;

@interface SYNDiscoverCategoriesCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *deSelectedColor;
@property (nonatomic, strong, readonly)  UIImageView *arrowImage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *arrowRightConstant;

@end
