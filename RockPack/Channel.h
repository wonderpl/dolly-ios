#import "_Channel.h"
#import "AbstractCommon.h"

@interface Channel : _Channel

@property (nonatomic) BOOL hasChangedSubscribeValue;

@property (nonatomic, strong) NSString* autoplayId;

@property (nonatomic, readonly) NSDateComponents* timeAgo;

+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (Channel *) instanceFromChannel: (Channel *) channel
                        andViewId: (NSString *) viewId
        usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
              ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (NSDictionary *)existingChannelsWithIds:(NSArray *)videoIds
				   inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSDictionary *)channelsFromDictionaries:(NSArray *)dictionaries
					inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void) addVideoInstanceFromDictionary: (NSDictionary *) videosInstanceDictionary;

- (void) addVideoInstancesFromDictionary: (NSDictionary *) videosInstancesDictionary;


@end
