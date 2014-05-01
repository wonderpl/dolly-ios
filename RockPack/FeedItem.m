#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "FeedItem.h"
#import "VideoInstance.h"
#import <TestFlight.h>

@implementation FeedItem

+ (FeedItem *)instanceFromResource:(AbstractCommon *)object {
    FeedItem *instance = [FeedItem insertInManagedObjectContext: object.managedObjectContext];
    
	[instance updateWithResource:object];
    
    return instance;
}

- (void)updateWithResource:(AbstractCommon *)resource {
	self.uniqueId = resource.uniqueId;
	
    if ([resource isKindOfClass: [VideoInstance class]])
    {
        VideoInstance *videoInstance = (VideoInstance *)resource;
        self.dateAdded = videoInstance.dateAdded;
        self.resourceTypeValue = FeedItemResourceTypeVideo;
        self.positionValue = videoInstance.positionValue;
    }
    else if ([resource isKindOfClass: [Channel class]])
    {
        Channel *channel = (Channel *)resource;
        self.dateAdded = channel.datePublished;
        self.resourceTypeValue = FeedItemResourceTypeChannel;
        self.positionValue = channel.positionValue;
    }
	
	self.viewId = resource.viewId;
}

+ (NSDictionary *)feedItemsWithIds:(NSArray *)feedItemIds inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[FeedItem entityName]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uniqueId IN %@", feedItemIds]];
	
	NSArray *feedItems = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
	
	return [NSDictionary dictionaryWithObjects:feedItems forKeys:[feedItems valueForKey:@"uniqueId"]];
}

+ (NSArray *)orderedFeedItemsWithIds:(NSArray *)feedItemIds inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSDictionary *feedItemsByIds = [self feedItemsWithIds:feedItemIds inManagedObjectContext:managedObjectContext];
	
	NSMutableArray *array = [NSMutableArray array];
	for (NSString *feedItemId in feedItemIds) {
		[array addObject:feedItemsByIds[feedItemId]];
	}
	return array;
}

+ (void)deleteFeedItemsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[FeedItem entityName]];
	
	NSArray *feedItems = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
	for (FeedItem *feedItem in feedItems) {
		[managedObjectContext deleteObject:feedItem];
	}
}

+ (void)deleteFeedItemsWithoutIds:(NSArray *)feedItemIds inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[FeedItem entityName]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"NOT (uniqueId IN %@)", feedItemIds]];
	
	NSArray *feedItems = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
	for (FeedItem *feedItem in feedItems) {
		[managedObjectContext deleteObject:feedItem];
	}
}

- (NSString *) description
{
    NSString *resourceString = self.resourceTypeValue == FeedItemResourceTypeChannel ? @"Channel" : @"VideoInstance";
    NSMutableString *responceString = [NSMutableString stringWithFormat: @"[FeedItem %@ (rsc:'%@', position:%lld)]", self.uniqueId, resourceString, self.positionValue];
    
    return responceString;
}


@end
