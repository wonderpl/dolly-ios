//
//  SYNFeedModel.m
//  dolly
//
//  Created by Sherman Lo on 4/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFeedModel.h"
#import "SYNPagingModel+Protected.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "FeedItem.h"
#import "VideoInstance.h"
#import "SYNVideoThumbnailDownloader.h"

@interface SYNFeedModel ()

@property (nonatomic, strong) NSArray *feedItems;
@property (nonatomic, strong) NSDictionary *videoInstancesById;
@property (nonatomic, strong) NSDictionary *channelsById;

@end

@implementation SYNFeedModel

#pragma mark - Factory

+ (instancetype)sharedModel {
	static SYNFeedModel *model;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		
		NSManagedObjectContext *managedObjectContext = appDelegate.mainManagedObjectContext;
		
		NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[FeedItem entityName]];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
		[fetchRequest setSortDescriptors:@[ sortDescriptor ]];
		
		NSArray *feedItems = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
		NSArray *feedItemIds = [feedItems valueForKey:@"uniqueId"];
		
		NSDictionary *videoInstancesById = [VideoInstance existingVideoInstancesWithIds:feedItemIds
																 inManagedObjectContext:managedObjectContext];
		NSDictionary *channelsById = [Channel existingChannelsWithIds:feedItemIds
											   inManagedObjectContext:managedObjectContext];
		
		NSArray *videoInstances = [VideoInstance orderedVideoInstancesWithIds:feedItemIds
													   inManagedObjectContext:managedObjectContext];
		
		model = [[self alloc] initWithItems:videoInstances totalItemCount:NSNotFound];
		model.videoInstancesById = videoInstancesById;
		model.channelsById = channelsById;
		model.feedItems = feedItems;
	});
	
	return model;
}

#pragma mark - Public

- (FeedItem *)feedItemAtindex:(NSInteger)index {
	return self.feedItems[index];
}

- (id)resourceForFeedItem:(FeedItem *)feedItem {
	if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
		return self.videoInstancesById[feedItem.uniqueId];
	} else {
		return self.channelsById[feedItem.uniqueId];
	}
}

- (NSInteger)feedItemCount {
	return [self.feedItems count];
}

- (NSInteger)itemIndexForFeedIndex:(NSInteger)feedIndex {
	NSIndexSet *channelIndexes = [self.feedItems indexesOfObjectsPassingTest:^BOOL(FeedItem *feedItem, NSUInteger idx, BOOL *stop) {
		if (idx == feedIndex) {
			*stop = YES;
			return NO;
		}
		return (feedItem.resourceTypeValue == FeedItemResourceTypeChannel);
	}];
	return (feedIndex - [channelIndexes count]);
}

- (void)reset {
	[super reset];
	
	self.feedItems = nil;
	self.videoInstancesById = nil;
	self.channelsById = nil;
}

#pragma mark - Overridden

- (void)loadItemsForRange:(NSRange)range
			 successBlock:(SYNPagingModelResultsBlock)successBlock
			   errorBlock:(SYNPagingModelErrorBlock)errorBlock {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	BOOL isFirstPage = (range.location == 0);
	
	__weak typeof(self) wself = self;
	[appDelegate.oAuthNetworkEngine feedUpdatesForUserId:appDelegate.currentOAuth2Credentials.userId
												   start:range.location
													size:range.length
									   completionHandler:^(NSDictionary *responseDictionary) {
										   
										   NSDictionary *content = responseDictionary[@"content"];
										   
										   NSArray *existingFeedItemIds = (isFirstPage ? @[] : [self.feedItems valueForKey:@"uniqueId"]);
										   
										   [self parseFeedResponse:content
												   existingFeedIds:existingFeedItemIds
												   completionBlock:^(NSArray *feedItems) {
													   
													   __strong typeof(self) sself = wself;
													   
													   NSManagedObjectContext *managedObjectContext = appDelegate.mainManagedObjectContext;
													   
													   NSNumber *total = content[@"total"];
													   
													   sself.feedItems = feedItems;
													   
													   NSArray *feedItemIds = [feedItems valueForKey:@"uniqueId"];
													   
													   sself.videoInstancesById = [VideoInstance existingVideoInstancesWithIds:feedItemIds
																										inManagedObjectContext:managedObjectContext];
													   sself.channelsById = [Channel existingChannelsWithIds:feedItemIds
																					  inManagedObjectContext:managedObjectContext];
													   
													   NSArray *videoInstances = [VideoInstance orderedVideoInstancesWithIds:feedItemIds
																									  inManagedObjectContext:managedObjectContext];
													   
													   [[SYNVideoThumbnailDownloader sharedDownloader] fetchThumbnailImagesForVideos:[videoInstances valueForKeyPath:@"video"]];
													   
													   successBlock(videoInstances, [total integerValue]);
												   }];
									   } errorHandler:^(NSDictionary *errorDictionary) {
										   errorBlock();
									   }];
}

#pragma mark - Private

- (void)parseFeedResponse:(NSDictionary *)response existingFeedIds:(NSArray *)existingFeedIds completionBlock:(MKNKUserSuccessBlock)completionBlock {
	
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	[managedObjectContext setPersistentStoreCoordinator:appDelegate.mainManagedObjectContext.persistentStoreCoordinator];
	
	__block NSArray *feedItemIds = nil;
	
	[managedObjectContext performBlock:^{
		NSArray *items = response[@"items"];
		
		NSArray *videoInstanceDictionaries = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"video != nil"]];
		NSDictionary *videoInstances = [VideoInstance videoInstancesFromDictionaries:videoInstanceDictionaries
															  inManagedObjectContext:managedObjectContext];
		
		NSArray *channelDictionaries = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"video == nil"]];
		NSDictionary *channels = [Channel channelsFromDictionaries:channelDictionaries
											inManagedObjectContext:managedObjectContext];
		
		NSDictionary *existingFeedItems = [FeedItem feedItemsWithIds:[items valueForKey:@"id"]
											  inManagedObjectContext:managedObjectContext];
		
		NSMutableArray *newFeedItemIds = [NSMutableArray array];
		for (NSDictionary *item in items) {
			NSString *feedItemId = item[@"id"];
			
			// Resource is either a video instance or a channel
			AbstractCommon *resource = (videoInstances[feedItemId] ?: channels[feedItemId]);
			
			FeedItem *feedItem = existingFeedItems[feedItemId];
			if (feedItem) {
				[feedItem updateWithResource:resource];
            } else {
				feedItem = [FeedItem instanceFromResource:resource];
            }
			
			[newFeedItemIds addObject:feedItemId];
		}
		
		// We want to dedupe the new feed items since MKNetworkKit is stupid and doesn't understand how caching should work
		NSMutableOrderedSet *uniqueFeedIds = [NSMutableOrderedSet orderedSetWithArray:existingFeedIds];
		[uniqueFeedIds addObjectsFromArray:newFeedItemIds];
		
		feedItemIds = [uniqueFeedIds array];
		
		[FeedItem deleteFeedItemsWithoutIds:feedItemIds inManagedObjectContext:managedObjectContext];
		
		[managedObjectContext save:nil];
	}];
	
	__weak NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	__block id observer = nil;
	observer = [notificationCenter addObserverForName:NSManagedObjectContextDidSaveNotification
											   object:managedObjectContext
												queue:[NSOperationQueue mainQueue]
										   usingBlock:^(NSNotification *note) {
											   
											   NSArray *feedItems = [FeedItem orderedFeedItemsWithIds:feedItemIds
																			   inManagedObjectContext:appDelegate.mainManagedObjectContext];
											   
											   completionBlock(feedItems);
											   
											   [notificationCenter removeObserver:observer
																			 name:NSManagedObjectContextDidSaveNotification
																		   object:managedObjectContext];
										   }];
}

@end
