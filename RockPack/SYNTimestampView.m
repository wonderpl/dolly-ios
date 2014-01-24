//
//  SYNTimestampView.m
//  dolly
//
//  Created by Sherman Lo on 23/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNTimestampView.h"
#import "NSString+Timecode.h"
#import "UIFont+SYNFont.h"

@interface SYNTimestampView ()

@property (nonatomic, strong) IBOutlet UILabel *timestampLabel;

@property (nonatomic, assign) CGFloat maxDuration;

@end

@implementation SYNTimestampView

+ (instancetype)viewWithMaxDuration:(NSTimeInterval)maxDuration {
	SYNTimestampView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYNTimestampView" owner:nil options:nil] firstObject];
	view.maxDuration = maxDuration;
	return view;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.timestampLabel.font = [UIFont lightCustomFontOfSize:self.timestampLabel.font.pointSize];
}

- (BOOL)translatesAutoresizingMaskIntoConstraints {
	return NO;
}

- (void)setTimestamp:(NSTimeInterval)timestamp {
	_timestamp = timestamp;
	
	self.timestampLabel.text = [NSString timecodeStringFromSeconds:timestamp];
	[self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
	CGSize contentSize = [super intrinsicContentSize];
	
	// We don't want the size of the label to change as the timestamp does so we want to make sure that we
	// have enough room to fit it, since zero's are the widest numbers, along with most of them we'll measure
	// the width of the max timestamp if it's set or the timestamp with all the digits replaced with zeros to
	// make sure that there's enough room
	NSString *timecodeString = [NSString timecodeStringFromSeconds:self.maxDuration];
	NSString *zeroedTimecodeString = [timecodeString stringByReplacingOccurrencesOfString:@"\\d"
																			   withString:@"0"
																				  options:NSRegularExpressionSearch
																					range:NSMakeRange(0, [timecodeString length])];
	
	CGRect rect = [zeroedTimecodeString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
													 options:NSStringDrawingUsesLineFragmentOrigin
												  attributes:@{ NSFontAttributeName : self.timestampLabel.font }
													 context:nil];
	
	return CGSizeMake(CGRectGetWidth(CGRectIntegral(rect)) + 10, contentSize.height);
}

@end
