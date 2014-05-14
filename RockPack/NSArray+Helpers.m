//
//  NSArray+Helpers.m
//  dolly
//
//  Created by Sherman Lo on 14/05/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "NSArray+Helpers.h"

@implementation NSArray (Helpers)

- (NSArray *)flattenedArray {
	NSMutableArray *array = [NSMutableArray array];
	
	for (id object in self) {
		if ([object isKindOfClass:[NSArray class]]) {
			[array addObjectsFromArray:object];
		} else {
			[array addObject:object];
		}
	}
	
	return array;
}

@end
