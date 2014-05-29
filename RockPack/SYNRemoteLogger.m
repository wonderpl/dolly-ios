//
//  SYNRemoteLogger.m
//  dolly
//
//  Created by Sherman Lo on 23/05/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNRemoteLogger.h"
#import "NSString+URLEncoding.h"

static NSString *const URLPrefix = @"http://dev.rockpack.com/log?message=%@";

@interface SYNRemoteLogger ()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSString *uuid;

@end

@implementation SYNRemoteLogger

+ (instancetype)sharedLogger {
	static dispatch_once_t onceToken;
	static SYNRemoteLogger *logger;
	dispatch_once(&onceToken, ^{
		logger = [[SYNRemoteLogger alloc] init];
	});
	return logger;
}

- (id)init {
	if (self = [super init]) {
		self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
		self.uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	}
	return self;
}

- (void)log:(NSString *)message {
	NSString *fullMessage = [NSString stringWithFormat:@"%@ (%f) - %@", self.uuid, [[NSDate date] timeIntervalSince1970], message];
	
	NSString *URLString = [NSString stringWithFormat:URLPrefix, [fullMessage urlEncodeUsingEncoding:NSUTF8StringEncoding]];
	NSURL *URL = [NSURL URLWithString:URLString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
	
	NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
	[task resume];
}

@end
