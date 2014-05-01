#import "_FeedItem.h"

@class VideoInstance;
@class Channel;
@class ChannelOwner;


@interface FeedItem : _FeedItem {}

+ (FeedItem *)instanceFromResource:(AbstractCommon *)object;

- (void)updateWithResource:(AbstractCommon *)resource;

+ (NSDictionary *)feedItemsWithIds:(NSArray *)feedItemIds inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)orderedFeedItemsWithIds:(NSArray *)feedItemIds inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)deleteFeedItemsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)deleteFeedItemsWithoutIds:(NSArray *)feedItemIds inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
