//
//  SYNChannelCategoryTableHeader.h
//  rockpack
//
//  Created by Mats Trovik on 24/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@interface SYNChannelCategoryTableHeader : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
/**
	button used to trigger the expansion of the subcategories.
 */
@property (weak, nonatomic) IBOutlet UIButton *headerButton;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;

@end
