//
//  SYNSearchVideoLikesModel.m
//  dolly
//
//  Created by Sherman Lo on 13/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchVideoLikesModel.h"
#import "SYNPagingModel+Protected.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"

@interface SYNSearchVideoLikesModel ()

@property (nonatomic, strong) NSString *videoId;

@end

@implementation SYNSearchVideoLikesModel

#pragma mark - Public class

+ (instancetype)modelWithVideoId:(NSString *)videoId {
	return [[self alloc] initWithVideoId:videoId];
}

#pragma mark - Init / Dealloc

- (instancetype)initWithVideoId:(NSString *)videoId {
	if (self = [super init]) {
		self.videoId = videoId;
	}
	return self;
}

#pragma mark - Overridden

- (void)loadItemsForRange:(NSRange)range {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	__weak typeof(self) wself = self;
	[appDelegate.networkEngine likesForVideoId:self.videoId
									   inRange:range
							 completionHandler:^(NSDictionary *response) {
								 __strong typeof(self) sself = wself;
								 
								 NSMutableArray *channelOwners = [NSMutableArray array];
								 for (NSDictionary *dictionary in response[@"users"][@"items"]) {
									 ChannelOwner *channelOwner = [ChannelOwner instanceFromDictionary:dictionary
																			 usingManagedObjectContext:appDelegate.mainManagedObjectContext
																				   ignoringObjectTypes:kIgnoreNothing];
									 [channelOwners addObject:channelOwner];
								 }
								 
								 sself.loadedItems = channelOwners;
								 sself.loadedRange = range;
								 sself.totalItemCount = [response[@"total"] integerValue];
								 
								 [sself handleDataUpdated];
							 } errorHandler:^(NSError *error) {
								 __strong typeof(self) sself = wself;
								 
								 [sself handleError];
							 }];
}	

@end