#import "_Recommendation.h"

@class ChannelOwner;
@interface Recommendation : _Recommendation {}

+ (Recommendation *)instanceFromDictionary:(NSDictionary *)dictionary
				 usingManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (nonatomic, strong, readonly) ChannelOwner *channelOwner;

@end
