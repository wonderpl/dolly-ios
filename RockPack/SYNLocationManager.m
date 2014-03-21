//
//  SYNLocationManager.m
//  dolly
//
//  Created by Sherman Lo on 17/03/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNLocationManager.h"
#import "SYNHTTPSessionManager.h"
#import "AppConstants.h"
#import "SYNStringResponseSerializer.h"
#import "SYNAppDelegate.h"

@interface SYNLocationManager ()

@property (nonatomic, copy) NSString *location;

@end

@implementation SYNLocationManager

+ (instancetype)sharedManager {
	static dispatch_once_t onceToken;
	static SYNLocationManager *sharedManager;
	dispatch_once(&onceToken, ^{
		sharedManager = [[SYNLocationManager alloc] init];
	});
	return sharedManager;
}

- (instancetype)init {
	if (self = [super init]) {
		self.location = @"";
	}
	return self;
}

- (void)updateLocationWithCompletion:(SYNNetworkStringResultBlock)competionBlock {
	competionBlock = competionBlock ?: ^(NSString *result){};
	
	SYNHTTPSessionManager *sessionManager = [SYNHTTPSessionManager secureAPIManager];
	sessionManager.responseSerializer = [SYNStringResponseSerializer serializer];
	
	NSURLSessionDataTask *task = [sessionManager GET:kLocationService
										  parameters:nil
											 success:^(NSURLSessionDataTask *task, id responseObject) {
												 self.location = responseObject;
												 
												 competionBlock(responseObject);
											 }
											 failure:^(NSURLSessionDataTask *task, NSError *error) {
												 self.location = @"";
												 
												 competionBlock(self.location);
											 }];
	
	[task resume];
}

- (void)setLocation:(NSString *)location {
	_location = location;
	
	SYNAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.ipBasedLocation = location;
}

- (NSString *)locale {
	SYNAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.currentUser) {
        return appDelegate.currentUser.locale;
    } else {
		NSString *localeIdentifier = [[NSLocale autoupdatingCurrentLocale] localeIdentifier];
		NSString *languageIdentifier = [NSLocale canonicalLanguageIdentifierFromString:localeIdentifier];
		
		return [languageIdentifier lowercaseString];
    }
}

@end
