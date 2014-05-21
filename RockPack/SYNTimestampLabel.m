//
//  SYNTimestampLabel.m
//  dolly
//
//  Created by Sherman Lo on 21/05/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNTimestampLabel.h"
#import "NSString+Timecode.h"

@implementation SYNTimestampLabel

- (void)setMaxTimestamp:(NSTimeInterval)maxTimestamp {
	_maxTimestamp = maxTimestamp;
	
	[self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
	NSString *durationString = [NSString timecodeStringFromSeconds:self.maxTimestamp];
	
	// We want a string with each of the digits in the duration replaced by zero since its one of the widest digits,
	// that way we'll know we have enough room for the text to change and not change the width of the label
	NSMutableString *zeroedDurationString = [NSMutableString string];
	for (NSInteger i = 0; i < [durationString length]; i++) {
		unichar character = [durationString characterAtIndex:i];
		BOOL isDigit = (character >= '0' && character <= '9');
		[zeroedDurationString appendString:(isDigit ? @"0" : @":")];
	}
	
	CGSize size = [zeroedDurationString sizeWithAttributes:@{ NSFontAttributeName : self.font }];
	
	return CGSizeMake(ceil(size.width), ceil(size.height));
}

@end
