#import "_FeedItem.h"

@class VideoInstance;
@class Channel;
@class ChannelOwner;


@interface FeedItem : _FeedItem {}

+ (FeedItem *) instanceFromDictionary: (NSDictionary *) dictionary
                               withId: (NSString*)aid
            usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

+ (FeedItem *) instanceFromResource: (AbstractCommon *) object;

@property (nonatomic, weak) NSManagedObject* placeholder;

@end
