//
//  SYNStringResponseSerializer.m
//  dolly
//
//  Created by Sherman Lo on 17/03/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNStringResponseSerializer.h"

@implementation SYNStringResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
	NSString *string = [[NSString alloc] initWithData:data encoding:self.stringEncoding];
	
	return [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
}

@end
