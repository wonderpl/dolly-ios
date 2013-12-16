//
//  SYNChannelVideosModel.m
//  dolly
//
//  Created by Sherman Lo on 9/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelVideosModel.h"
#import "SYNPagingModel+Protected.h"
#import "SYNNetworkOperationJsonObject.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"

@interface SYNChannelVideosModel ()

@property (nonatomic, strong) Channel *channel;

@end

@implementation SYNChannelVideosModel

#pragma mark - Public class

+ (instancetype)modelWithChannel:(Channel *)channel {
	return [[self alloc] initWithChannel:channel];
}

#pragma mark - Init / Dealloc

- (instancetype)initWithChannel:(Channel *)channel {
	if (self = [super init]) {
		self.channel = channel;
		
		self.loadedItems = [channel.videoInstances array];
		self.loadedRange = NSMakeRange(0, [channel.videoInstances count]);
		self.totalItemCount = channel.totalVideosValueValue;

	}
	return self;
}

#pragma mark - Overridden

- (void)loadItemsForRange:(NSRange)range {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	__weak typeof(self) wself = self;
	MKNKUserSuccessBlock successBlock = ^(NSDictionary *response) {
		__strong typeof(self) sself = wself;
		
		[sself.channel addVideoInstancesFromDictionary:response];
		[sself.channel.managedObjectContext save:nil];
		
		sself.loadedRange = range;
		sself.loadedItems = [self.channel.videoInstances array];
		sself.totalItemCount = sself.channel.totalVideosValueValue;
		
		[sself handleDataUpdated];
	};

	// define success block //
	MKNKUserErrorBlock errorBlock = ^(NSDictionary *response) {
		[self handleError];
	};

	// We want to load the current user's channel securely since it isn't cached and we always want to
	// make sure we get the latest data for the user's own channel in case they've made an edit
	if ([self.channel.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId]) {
		[appDelegate.oAuthNetworkEngine videosForChannelForUserId:appDelegate.currentUser.uniqueId
														channelId:self.channel.uniqueId
														  inRange:range
												completionHandler:successBlock
													 errorHandler:errorBlock];
	} else {
		[appDelegate.networkEngine videosForChannelForUserId:self.channel.channelOwner.uniqueId
												   channelId:self.channel.uniqueId
													 inRange:range
										   completionHandler:successBlock
												errorHandler:errorBlock];
	}
}

@end
