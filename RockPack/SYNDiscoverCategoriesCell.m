//
//  SYNCategoryCollectionViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 16/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNDiscoverCategoriesCell.h"
#import "UIFont+SYNFont.h"

@interface SYNDiscoverCategoriesCell ()

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UIView* dimmingView;
@property (nonatomic, strong) IBOutlet UIView *separator;

@end

@implementation SYNDiscoverCategoriesCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
    self.label.font = [UIFont lightCustomFontOfSize: self.label.font.pointSize];
}

@end
