#import "_Recomendation.h"

@interface Recomendation : _Recomendation {}

+ (Recomendation *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@end
