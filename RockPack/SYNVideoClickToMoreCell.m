//
//  SYNVideoClickToMoreCell.m
//  dolly
//
//  Created by Sherman Lo on 11/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoClickToMoreCell.h"
#import "UIColor+SYNColor.h"

@interface SYNVideoClickToMoreCell ()

@property (nonatomic, strong) IBOutlet UIButton *button;

@end

@implementation SYNVideoClickToMoreCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.button.layer.cornerRadius = (CGRectGetHeight(self.button.frame) / 2.0);
	self.button.layer.borderColor = [[UIColor dollyButtonGreenColor] CGColor];
	self.button.layer.borderWidth = 2.0;
	
	self.button.tintColor = [UIColor dollyButtonGreenColor];
}

- (void)setTitle:(NSString *)title {
	_title = title;
	
	self.button.hidden = ([title length] == 0);
	[self.button setTitle:title forState:UIControlStateNormal];
}

- (IBAction)buttonPressed:(UIButton *)button {
	[self.delegate clickToMoreButtonPressed];
}

@end
