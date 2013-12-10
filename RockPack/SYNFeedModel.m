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

@interface SYNFeedModel ()

@property (nonatomic, strong) NSArray *feedItems;
@property (nonatomic, strong) NSArray *videoInstances;
@property (nonatomic, strong) NSDictionary *videoInstancesById;
@property (nonatomic, strong) NSDictionary *channelsById;

@end

@implementation SYNFeedModel

#pragma mark - Public

- (Channel *)channelForFeedItem:(FeedItem *)feedItem {
	FeedItem *actualFeedItem = feedItem;
	if (feedItem.itemTypeValue == FeedItemTypeAggregate) {
		actualFeedItem = [feedItem.feedItems anyObject];
	}
	
	Channel *channel = nil;
	if (actualFeedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
		VideoInstance *videoInstance = self.videoInstancesById[actualFeedItem.resourceId];
		channel = videoInstance.channel;
	} else if (actualFeedItem.resourceTypeValue == FeedItemResourceTypeChannel) {
		channel = self.channelsById[actualFeedItem.resourceId];
	}
	return channel;
}

- (NSArray *)videoInstancesForFeedItem:(FeedItem *)feedItem {
	NSMutableArray* videoInstances = [NSMutableArray array];
	
	if (feedItem.itemTypeValue == FeedItemTypeAggregate) {
		for (FeedItem* childFeedItem in feedItem.feedItems) {
			[videoInstances addObject:self.videoInstancesById[childFeedItem.resourceId]];
		}
	} else {
		[videoInstances addObject:self.videoInstancesById[feedItem.resourceId]];
	}
	
	return videoInstances;
}

- (NSArray *)channelsForFeedItem:(FeedItem *)feedItem {
	NSMutableArray* channels = [NSMutableArray array];
	
	if (feedItem.itemTypeValue == FeedItemTypeAggregate) {
		for (FeedItem* childFeedItem in feedItem.feedItems) {
			[channels addObject:self.channelsById[childFeedItem.resourceId]];
		}
	} else {
		[channels addObject:self.channelsById[feedItem.resourceId]];
	}
	
	return channels;
}

- (NSArray *)videoInstancesForFeedItems:(NSArray *)feedItems {
	NSMutableArray *videoInstances = [NSMutableArray array];
	
	NSArray *sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES] ];
	for (FeedItem *feedItem in feedItems) {
		if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
			if (feedItem.itemTypeValue == FeedItemTypeAggregate) {
				for (FeedItem *childFeedItem in [feedItem.feedItems sortedArrayUsingDescriptors:sortDescriptors]) {
					[videoInstances addObject:self.videoInstancesById[childFeedItem.resourceId]];
				}
			} else {
				[videoInstances addObject:self.videoInstancesById[feedItem.resourceId]];
			}
		}
	}
	
	return videoInstances;
}

- (NSInteger)videoIndexForIndexPath:(NSIndexPath *)indexPath {
	__block NSInteger index = 0;
	[self.feedItems enumerateObjectsUsingBlock:^(FeedItem *feedItem, NSUInteger idx, BOOL *stop) {
		if (idx >= indexPath.section) {
			*stop = YES;
			return;
		}
		if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
			index += feedItem.itemCountValue;
		}
	}];
	return index + indexPath.item;
}

#pragma mark - Getters / Setters

- (void)setMode:(SYNFeedModelMode)mode {
	_mode = mode;
	
	self.loadedItems = (mode == SYNFeedModelModeFeed ? self.feedItems : self.videoInstances);
}

#pragma mark - Overridden

- (void)loadItemsForRange:(NSRange)range {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
    __weak typeof(self) wself = self;
    [appDelegate.oAuthNetworkEngine feedUpdatesForUserId:appDelegate.currentOAuth2Credentials.userId
                                                   start:range.location
                                                    size:range.length
                                       completionHandler:^(NSDictionary *responseDictionary) {
										   BOOL append = (range.location > 0);
										   
                                           NSDictionary *contentItems = responseDictionary[@"content"];
										   
										   SYNMainRegistry *mainRegistry = appDelegate.mainRegistry;
										   
                                           [mainRegistry performInBackground: ^BOOL (NSManagedObjectContext *backgroundContext) {
                                               return [mainRegistry registerDataForSocialFeedFromItemsDictionary:contentItems
																									 byAppending:append];
                                           } completionBlock: ^(BOOL registryResultOk) {
											   __strong typeof(self) sself = wself;
											   
											   if (!registryResultOk) {
												   [self handleError];
												   [sself.delegate pagingModelErrorOccurred];
												   return;
											   }
											   
											   NSNumber *total = contentItems[@"total"];
											   NSArray *feedItems = [sself fetchFeedItems];
											   
											   sself.feedItems = feedItems;
											   
											   sself.videoInstancesById = [self fetchVideoInstancesByIds];
											   sself.channelsById = [self fetchChannelsByIds];
											   
											   NSArray *videoInstances = [sself videoInstancesForFeedItems:feedItems];
											   sself.videoInstances = videoInstances;
											   
											   sself.loadedRange = range;
											   sself.loadedItems = (sself.mode == SYNFeedModelModeFeed ? feedItems : videoInstances);
											   sself.totalItemCount = [total integerValue];
											   
											   [sself handleDataUpdated];
										   }];
                                       } errorHandler:^(NSDictionary *errorDictionary) {
										   [self handleError];
                                       }];
}

#pragma mark - Private

- (NSArray *)fetchFeedItems {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[FeedItem entityName]];
	
	// if the aggregate has a parent FeedItem then it should NOT be displayed since it is going to be part of an aggregate...
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"viewId == %@ AND aggregate == nil", kFeedViewId];
	
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:NO],
									 [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
	
	return [appDelegate.mainManagedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (NSDictionary *)fetchChannelsByIds {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Channel entityName]];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"viewId == %@", kFeedViewId];
    
    NSArray *results = [appDelegate.mainManagedObjectContext executeFetchRequest: fetchRequest error:nil];
	
	return [NSDictionary dictionaryWithObjects:results forKeys:[results valueForKey:@"uniqueId"]];
}

- (NSDictionary *)fetchVideoInstancesByIds {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VideoInstance entityName]];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"viewId == %@", kFeedViewId];
	
	NSArray *results = [appDelegate.mainManagedObjectContext executeFetchRequest:fetchRequest error:nil];
	
	return [NSDictionary dictionaryWithObjects:results forKeys:[results valueForKey:@"uniqueId"]];
}

@end
