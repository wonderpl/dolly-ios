//
//  SYNDiscoverSectionHeaderView.m
//  dolly
//
//  Created by Cong Le on 02/04/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNDiscoverSectionHeaderView.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"

@interface SYNDiscoverSectionHeaderView ()


@end

@implementation SYNDiscoverSectionHeaderView


- (void) awakeFromNib {
	[super awakeFromNib];
	self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
}

- (void) prepareForReuse {
	[super prepareForReuse];
}


- (void)setTitleText : (NSString*) string {
    
    if(!string)
        return;
    
	string = [string uppercaseString];
	UIColor *color = [UIColor colorWithRed: (112.0f / 255.0f)
									 green: (123.0f / 255.0f)
									  blue: (123.0f / 255.0f)
									 alpha: 1.0f];
	
	NSDictionary *attributes = @{
								 NSKernAttributeName : @(2.5f),
								 NSFontAttributeName : [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize],
								 NSForegroundColorAttributeName : color
								 };
	
	NSAttributedString *attributedString =
    [[NSAttributedString alloc]
	 initWithString:string attributes:attributes];
	
	self.titleLabel.attributedText = attributedString;
}

@end
