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
		return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
	}
	
	return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
}

+ (NSString *)friendlyLengthFromTimeInterval:(NSTimeInterval)timeInterval {
	NSInteger timeInSeconds = timeInterval;
	
	NSInteger hours = ((timeInSeconds / 60) / 60);
	NSInteger minutes = MAX(1, round((timeInSeconds - hours * 3600) / 60.0));
	
	if (minutes == 60) {
		hours++;
		minutes = 0;
	}
	
	if (hours) {
		NSInteger roundedMinutes = round((minutes % 60) / 15.0) * 15;
		if (roundedMinutes == 60) {
			hours++;
			roundedMinutes = 0;
		}
		if (roundedMinutes) {
			return [NSString stringWithFormat:@"%d hr %d min watch", hours, roundedMinutes];
		} else {
			return [NSString stringWithFormat:@"%d hr watch", hours];
		}
	}

	return [NSString stringWithFormat:@"%d min watch", minutes];
}

@end
