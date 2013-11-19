#import "_Video.h"
#import "AbstractCommon.h"

extern NSString *const VideoSourceYouTube;
extern NSString *const VideoSourceOoyala;

@interface Video : _Video

+ (Video *) instanceFromDictionary: (NSDictionary *) dictionary
         usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
               ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (Video *) instanceFromVideo: (Video *) video
    usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;


- (UIImage *) thumbnailImage;
- (NSURL *) localVideoURL;

@end
