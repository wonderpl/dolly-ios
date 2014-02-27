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
#import "VideoInstance.h"

@interface SYNChannelVideosModel ()

@property (nonatomic, strong) Channel *channel;

@property (nonatomic, assign) BOOL isSavingNextPage;

@end

@implementation SYNChannelVideosModel

#pragma mark - Public class

+ (instancetype)modelWithChannel:(Channel *)channel {
	return [[self alloc] initWithChannel:channel];
}

#pragma mark - Init / Dealloc

- (instancetype)initWithChannel:(Channel *)channel {
	if (self = [super initWithItems:[channel.videoInstances array] totalItemCount:channel.totalVideosValueValue]) {
		self.channel = channel;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(managedObjectContextDidSave:)
													 name:NSManagedObjectContextDidSaveNotification
												   object:channel.managedObjectContext];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Overridden

- (void)loadItemsForRange:(NSRange)range {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	__weak typeof(self) wself = self;
	MKNKUserSuccessBlock successBlock = ^(NSDictionary *response) {
		__strong typeof(self) sself = wself;
		
		self.isSavingNextPage = YES;
        
		[sself.channel addVideoInstancesFromDictionary:response];
		[sself.channel.managedObjectContext save:nil];
		
		sself.loadedItems = [self.channel.videoInstancesSet array];
		sself.totalItemCount = sself.channel.totalVideosValueValue;
		
		[sself handleDataUpdatedForRange:range];
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

- (void)managedObjectContextDidSave:(NSNotification *)notification {
	// If we're saving the next page then we're handling updating the videos in there so there isn't any need to do anything here
	if (!self.isSavingNextPage) {
		self.isSavingNextPage = NO;
		
		[self resetWithItems:[self.channel.videoInstances array] totalItemCount:self.channel.totalVideosValueValue];
		
		[self.delegate pagingModelDataUpdated:self];
	}
}

@end
