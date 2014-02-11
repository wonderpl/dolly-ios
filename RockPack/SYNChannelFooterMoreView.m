//
//  SYNChannelFooterMoreView.m
//  rockpack
//
//  Created by Michael Michailidis on 04/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelFooterMoreView.h"
#import "UIColor+SYNColor.h"
@interface SYNChannelFooterMoreView ()

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@end

@implementation SYNChannelFooterMoreView

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.activityIndicator.color = [UIColor dollyActivityIndicator];
}

- (void)setShowsLoading:(BOOL)showsLoading {
	if (_showsLoading == showsLoading)
		return;

	_showsLoading = showsLoading;
	
	if (_showsLoading) {
		[self.activityIndicator startAnimating];
	} else {
		[self.activityIndicator stopAnimating];
	}
}

@end
