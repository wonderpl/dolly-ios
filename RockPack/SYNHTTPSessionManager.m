//
//  SYNHTTPSessionManager.m
//  dolly
//
//  Created by Sherman Lo on 12/03/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNHTTPSessionManager.h"

@implementation SYNHTTPSessionManager

+ (instancetype)standardAPIManager {
	NSString *hostName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIHostName"];
	NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", hostName]];
	
	return [[SYNHTTPSessionManager alloc] initWithBaseURL:baseURL];
}

+ (instancetype)secureAPIManager {
	NSString *hostName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SecureAPIHostName"];
	NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", hostName]];
	
	return [[SYNHTTPSessionManager alloc] initWithBaseURL:baseURL];
}

@end
