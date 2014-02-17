//
//  NSRegularExpression+Username.m
//  dolly
//
//  Created by Sherman Lo on 17/02/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "NSRegularExpression+Username.h"

@implementation NSRegularExpression (Username)

+ (NSRegularExpression *)usernameRegex {
	static NSRegularExpression *regex;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		regex = [NSRegularExpression regularExpressionWithPattern:@"(?:^|(?<=\\W))@(\\w+)" options:NSRegularExpressionCaseInsensitive error:nil];
	});
	return regex;
}

@end
