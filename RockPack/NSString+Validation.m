//
//  NSString+Validation.m
//  dolly
//
//  Created by Sherman Lo on 27/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "NSString+Validation.h"
#import "RegexKitLite.h"

@implementation NSString (Validation)

- (BOOL)isValidFullName {
	return [self isMatchedByRegex:@"^[a-zA-Z\\.]+$"];
}

- (BOOL)isValidUsername {
	return [self isMatchedByRegex:@"^[a-zA-Z0-9\\._]+$"];
}

- (BOOL)isValidEmail {
	return [self isMatchedByRegex:@"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"];
}

- (BOOL)isValidPassword {
	return [self isMatchedByRegex:@"^[a-zA-Z0-9\\._]+$"];
}

@end
