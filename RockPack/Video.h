#import "_Video.h"
#import "AbstractCommon.h"

extern NSString *const VideoSourceYouTube;
extern NSString *const VideoSourceOoyala;

@interface Video : _Video

@property (nonatomic, assign, readonly) BOOL hasLink;

+ (Video *) instanceFromDictionary: (NSDictionary *) dictionary
         usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
               ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (Video *) instanceFromVideo: (Video *) video
    usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

+ (NSDictionary *)videosFromDictionaries:(NSArray *)dictionaries
				  inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
