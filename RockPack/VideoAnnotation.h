#import "_VideoAnnotation.h"

@interface VideoAnnotation : _VideoAnnotation {}

+ (NSArray *)videoAnnotationsFromDictionaries:(NSArray *)dictionaries
					   inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (CGRect)frameForAnnotationInRect:(CGRect)rect;

@end
