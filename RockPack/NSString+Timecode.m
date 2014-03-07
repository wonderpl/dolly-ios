//
//  NSString+Timecode.m
//  rockpack
//
//  Created by Nick Banks on 14/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "NSString+Timecode.h"

@implementation NSString (Timecode)

+ (NSString *)timecodeStringFromSeconds:(NSTimeInterval)timeSeconds {
	NSInteger totalSeconds = timeSeconds;
	
	NSInteger hours = (totalSeconds / 3600);
	NSInteger minutes = ((totalSeconds / 60) % 60);
	NSInteger seconds = (totalSeconds % 60);
	
	if (hours) {
		return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
	}
	
	return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

@end
