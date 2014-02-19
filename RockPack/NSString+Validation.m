//
//  NSString+Validation.m
//  dolly
//
//  Created by Sherman Lo on 27/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

- (BOOL)isValidUsername {
	return [self matchesRegex:@"^[a-zA-Z0-9\\._]+$"];
}

- (BOOL)isValidEmail {
	return [self matchesRegex:@"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"];
}

- (BOOL)isValidPassword {
	return [self matchesRegex:@"^[a-zA-Z0-9\\._]+$"];
}

- (BOOL)matchesRegex:(NSString *)regex {
	NSRange matchRange = [self rangeOfString:regex options:NSRegularExpressionSearch];
	return (matchRange.location == 0 && matchRange.length == [self length]);
}

@end
