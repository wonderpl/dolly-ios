#import "_Comment.h"

@interface Comment : _Comment {}

+ (Comment *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;


@end
