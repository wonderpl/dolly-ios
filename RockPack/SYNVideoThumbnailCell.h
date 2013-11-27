//
//  SYNVideoThumbnailCell.h
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@interface SYNVideoThumbnailCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UILabel *titleLabel;

+ (UINib *)nib;
+ (NSString *)reuseIdentifier;

- (void)setImageWithURL:(NSString *)urlString;

@end
