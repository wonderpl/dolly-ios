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
@property (strong, nonatomic) IBOutlet UIImageView *rightImage;

@end

@implementation SYNDiscoverCategoriesCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
    self.label.font = [UIFont semiboldCustomFontOfSize: self.label.font.pointSize];\
	self.rightImage.hidden = YES;

}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.backgroundColor = [UIColor clearColor];
	self.label.textColor = [UIColor whiteColor];
	
	self.rightImage.hidden = YES;
}


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self updateBackgroundColor];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = [UIColor blackColor];
    
    [self updateBackgroundColor];
}

- (void)setDeSelectedColor:(UIColor *)deSelectedColor {
    _deSelectedColor = deSelectedColor;
    
    [self updateBackgroundColor];
}


- (void)updateBackgroundColor {
    if (self.selected) {
        self.backgroundColor =  [UIColor blackColor];
		[self.label setTextColor:[UIColor whiteColor]];
	} else {
        self.backgroundColor =  [UIColor whiteColor];
		[self.label setTextColor:[UIColor blackColor]];
    }

}

@end
