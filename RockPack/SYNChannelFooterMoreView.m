//
//  SYNChannelFooterMoreView.m
//  rockpack
//
//  Created by Michael Michailidis on 04/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelFooterMoreView.h"

@interface SYNChannelFooterMoreView ()

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@end

@implementation SYNChannelFooterMoreView

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.activityIndicator.color = [UIColor colorWithRed: (11.0/255.0)
												   green: (166.0/255.0)
													blue: (171.0/255.0)
												   alpha: (1.0)];
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
