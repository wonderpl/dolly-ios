#import "_Channel.h"
#import "AbstractCommon.h"

@interface Channel : _Channel

@property (nonatomic) BOOL hasChangedSubscribeValue;
@property (nonatomic) NSInteger totalVideosValue;

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

- (void) addVideoInstanceFromDictionary: (NSDictionary *) videosInstanceDictionary;

- (void) addVideoInstancesFromDictionary: (NSDictionary *) videosInstancesDictionary;


@end
