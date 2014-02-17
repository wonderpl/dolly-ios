#import "_ChannelOwner.h"
#import "AbstractCommon.h"

@interface ChannelOwner : _ChannelOwner

@property (nonatomic, readonly) NSString *thumbnailLargeUrl;

+ (ChannelOwner *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                      ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (ChannelOwner *) instanceFromChannelOwner: (ChannelOwner *) existingChannelOwner
                                  andViewId: (NSString *) viewId
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (ChannelOwner *)channelOwnerWithUsername:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

- (NSDictionary *) channelsDictionary;

- (void) setSubscriptionsDictionary : (NSDictionary *) subscriptionsDictionary;

- (void) addChannelsFromDictionary : (NSDictionary *) channelsDictionary;
- (void) addSubscriptionsFromDictionary : (NSDictionary *) subscriptionsDictionary;

@end
