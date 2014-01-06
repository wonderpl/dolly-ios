//
//  SYNTimecodeLabel.m
//  dolly
//
//  Created by Sherman Lo on 6/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNTimecodeLabel.h"
#import "NSString+Timecode.h"

@implementation SYNTimecodeLabel

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.textAlignment = NSTextAlignmentCenter;
}

#pragma mark - Getters / Setters

- (void)setTimecode:(NSTimeInterval)timecode {
	_timecode = timecode;
	
	self.text = [NSString timecodeStringFromSeconds:timecode];
}

#pragma mark - Overridden

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
	// We don't want the size of the label to change as the timestamp does so we want to make sure that we
	// have enough room to fit it, since zero's are the widest numbers, along with most of them we'll measure
	// the width of the max timestamp if it's set or the timestamp with all the digits replaced with zeros to
	// make sure that there's enough room
	NSString *timecodeString = [NSString timecodeStringFromSeconds:(self.maxTimecode ?: self.timecode)];
	NSString *zeroedTimecodeString = [timecodeString stringByReplacingOccurrencesOfString:@"\\d"
																			   withString:@"0"
																				  options:NSRegularExpressionSearch
																					range:NSMakeRange(0, [timecodeString length])];
	
	CGRect rect = [zeroedTimecodeString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
													 options:NSStringDrawingUsesLineFragmentOrigin
												  attributes:@{ NSFontAttributeName : self.font }
													 context:nil];
	return CGRectIntegral(rect);
}

@end
