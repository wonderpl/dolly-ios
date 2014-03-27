//
//  NSString+TestHelpers.m
//  dolly
//
//  Created by Sherman Lo on 27/03/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "NSString+TestHelpers.h"

@implementation NSString (TestHelpers)

+ (NSString *)testStringWithLength:(NSInteger)length {
	NSMutableString *string = [NSMutableString string];
	for (int i = 0; i < length; i++) {
		[string appendString:@"0"];
	}
	return [string copy];
}

@end
