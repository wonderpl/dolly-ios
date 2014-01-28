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

@property (nonatomic, strong) CALayer *separatorLayerMask;

@end

@implementation SYNDiscoverCategoriesCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
    self.label.font = [UIFont lightCustomFontOfSize: self.label.font.pointSize];
	
	self.separator.layer.mask = self.separatorLayerMask;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
	self.dimmingView.hidden = !selected;
}

- (CALayer *)separatorLayerMask {
	if (!_separatorLayerMask) {
		CAGradientLayer *mask = [CAGradientLayer layer];
		mask.colors = @[ (id) [[UIColor clearColor] CGColor],
						 (id) [[UIColor whiteColor] CGColor],
						 (id) [[UIColor clearColor] CGColor] ];
		mask.locations = @[ @0.0, @0.5, @1.0 ];
		mask.startPoint = CGPointMake(0.0, 0.5);
		mask.endPoint = CGPointMake(1.0, 0.5);
		
		self.separatorLayerMask = mask;
	}
	return _separatorLayerMask;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
	[super layoutSublayersOfLayer:layer];
	
	self.separatorLayerMask.frame = self.separator.bounds;
}


@end
