//
//  SYNVideoActionsCell.m
//  dolly
//
//  Created by Sherman Lo on 11/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoActionsCell.h"
#import "SYNVideoActionsBar.h"

@interface SYNVideoActionsCell ()

@property (nonatomic, strong) SYNVideoActionsBar *actionsBar;

@end

@implementation SYNVideoActionsCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.actionsBar.frame = self.contentView.bounds;
	[self.contentView addSubview:self.actionsBar];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;

}

- (SYNVideoActionsBar *)actionsBar {
	if (!_actionsBar) {
		SYNVideoActionsBar *actionsBar = [SYNVideoActionsBar bar];
		actionsBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		self.actionsBar = actionsBar;
	}
	return _actionsBar;
}

@end
