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

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.backgroundColor = [UIColor clearColor];
}


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self updateBackgroundColor];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    
    [self updateBackgroundColor];
}

- (void)setDeSelectedColor:(UIColor *)deSelectedColor {
    _deSelectedColor = deSelectedColor;
    
    [self updateBackgroundColor];
}


- (void)updateBackgroundColor {
    if (self.selected) {
        self.backgroundColor =  self.selectedColor;
    } else {
        self.backgroundColor = self.deSelectedColor;
    }

}

@end
