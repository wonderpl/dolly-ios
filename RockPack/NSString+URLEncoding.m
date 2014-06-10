//
//  NSString+URLEncoding.m
//  dolly
//
//  Created by Sherman Lo on 23/05/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
															   (CFStringRef)self,
															   NULL,
															   (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
															   CFStringConvertNSStringEncodingToEncoding(encoding));
}

@end
