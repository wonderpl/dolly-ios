#import "_Genre.h"

@interface Genre : _Genre {}

+ (Genre *) instanceFromDictionary: (NSDictionary *) dictionary
         usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

- (NSArray *) getSubGenreIdArray;

- (NSString *)genreName;

@end
