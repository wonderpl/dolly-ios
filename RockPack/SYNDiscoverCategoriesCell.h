//
//  SYNCategoryCollectionViewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 16/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNDiscoverCategoriesCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel* label;

@property (nonatomic, strong) IBOutlet UIImageView* arrow;

@property (nonatomic, strong) IBOutlet UIView* separator;

@end
