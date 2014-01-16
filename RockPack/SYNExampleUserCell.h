//
//  SYNExampleUserCell.h
//  dolly
//
//  Created by Sherman Lo on 14/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNExampleUserCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *descriptionLabel;

@end
