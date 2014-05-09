//
//  SYNVideoButtonBar.m
//  dolly
//
//  Created by Sherman Lo on 16/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoActionsBar.h"
#import "UIFont+SYNFont.h"

@interface SYNVideoActionsBar ()

@property (nonatomic, weak) IBOutlet UIButton *shopButton;
@property (nonatomic, weak) IBOutlet UIButton *favouriteButton;

@end

@implementation SYNVideoActionsBar

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.shopButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.shopButton.titleLabel.font.pointSize];
}

+ (instancetype)bar {
	UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
	return [[nib instantiateWithOwner:self options:nil] firstObject];
}

- (IBAction)favouriteButtonPressed:(UIButton *)button {
	[self.delegate videoActionsBar:self favouritesButtonPressed:button];
}

- (IBAction)annotationButtonPressed:(UIButton *)button {
	[self.delegate videoActionsBar:self annotationButtonPressed:button];
}

- (IBAction)addToChannelButtonPressed:(UIButton *)button {
	[self.delegate videoActionsBar:self addToChannelButtonPressed:button];
}

- (IBAction)shareButtonPressed:(UIButton *)button {
	[self.delegate videoActionsBar:self shareButtonPressed:button];
}

@end
