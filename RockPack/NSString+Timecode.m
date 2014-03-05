//
//  NSString+Timecode.m
//  rockpack
//
//  Created by Nick Banks on 14/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "NSString+Timecode.h"

@implementation NSString (Timecode)

+ (NSString *) timecodeStringFromSeconds: (float) timeSeconds
{
    // Round down to nearest second
    int time = (int) timeSeconds;
    
    // We should display slightly differently if we have a length in hours
    if (time > 3600)
    {
        return [NSString stringWithFormat:@"%d:%02d:%02d", time / 3600, (time / 60) % 60, time % 60];
    }
    else
    {
        return [NSString stringWithFormat:@"%d:%02d", (time / 60) % 60, time % 60];
    }
}

+ (NSString *)paddedTimecodeStringFromSeconds:(NSTimeInterval)seconds {
	NSInteger timeSeconds = seconds;
	
    if (((timeSeconds / 60)/60) % 60>0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", ((timeSeconds / 60)/60) % 60, (timeSeconds / 60) % 60, timeSeconds % 60];
        
    }
    
	return [NSString stringWithFormat:@"%02d:%02d", (timeSeconds / 60) % 60, timeSeconds % 60];
}

@end
