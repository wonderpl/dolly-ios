#import "_Recomendation.h"

@class ChannelOwner;
@interface Recomendation : _Recomendation {}

+ (Recomendation *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@property (nonatomic, readonly) ChannelOwner* channelOwner;

@end
