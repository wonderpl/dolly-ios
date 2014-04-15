//
//  SYNVideoActionsCell.m
//  dolly
//
//  Created by Sherman Lo on 11/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoActionsCell.h"

@implementation SYNVideoActionsCell

- (IBAction)shareButtonPressed:(UIButton *)button {
	[self.delegate videoActionsSharePressed];
}

- (IBAction)addToChannelButtonPressed:(UIButton *)button {
	[self.delegate videoActionsAddToChannelPressed];
}

- (IBAction)favouriteButtonPressed:(UIButton *)button {
	[self.delegate videoActionsFavouritePressed];
}

@end
