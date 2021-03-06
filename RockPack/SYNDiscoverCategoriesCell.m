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
@property (strong, nonatomic) IBOutlet UIImageView *arrowImage;

@end

@implementation SYNDiscoverCategoriesCell

- (void)awakeFromNib {
	[super awakeFromNib];
    self.label.font = [UIFont semiboldCustomFontOfSize: self.label.font.pointSize];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;

}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.backgroundColor = [UIColor clearColor];
	self.label.textColor = [UIColor blackColor];
	self.arrowImage.hidden = YES;
}


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
	if (selected) {
        self.arrowImage.hidden = NO;
    } else {
        self.arrowImage.hidden = YES;
    }
}


@end
