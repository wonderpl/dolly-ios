#import "_VideoInstance.h"
#import "AbstractCommon.h"

@interface VideoInstance : _VideoInstance

@property (nonatomic) BOOL selectedForVideoQueue;
@property (nonatomic, strong) NSNumber* starredByUser;
@property (nonatomic) BOOL starredByUserValue;
@property (nonatomic, readonly) NSString* thumbnailURL;

@property (nonatomic, readonly) NSDateComponents* timeAgo;

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                       ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                            existingVideos: (NSArray *) existingVideos;

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                            existingVideos: (NSArray *) existingVideos;

+ (VideoInstance *) instanceFromVideoInstance: (VideoInstance *) existingInstance
                    usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                          ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

+ (NSDictionary *)existingVideoInstancesWithIds:(NSArray *)videoInstanceIds
						 inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSDictionary *)videoInstancesFromDictionaries:(NSArray *)dictionaries
						  inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)orderedVideoInstancesWithIds:(NSArray *)videoInstanceIds
				   inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
