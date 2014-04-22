//
//  SYNVideoButtonBar.m
//  dolly
//
//  Created by Sherman Lo on 16/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoActionsBar.h"

@implementation SYNVideoActionsBar

+ (instancetype)bar {
	UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
	return [[nib instantiateWithOwner:self options:nil] firstObject];
}

- (IBAction)favouriteButtonPressed:(UIButton *)button {
	[self.delegate videoActionsBar:self favouritesButtonPressed:button];
}

- (IBAction)addToChannelButtonPressed:(UIButton *)button {
	[self.delegate videoActionsBar:self addToChannelButtonPressed:button];
}

- (IBAction)shareButtonPressed:(UIButton *)button {
	[self.delegate videoActionsBar:self shareButtonPressed:button];
}

@end
