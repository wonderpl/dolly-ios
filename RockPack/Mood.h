#import "_Mood.h"

@interface Mood : _Mood {}


+ (Mood *) instanceFromDictionary: (NSDictionary *) dictionary
        usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;


@end
