//
//  SYNVideoThumbnailSmallCell.h
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@interface SYNVideoThumbnailSmallCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UILabel *titleLabel;

+ (UINib *)nib;

- (void)setImageWithURL:(NSString *)urlString;

@end
