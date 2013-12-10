// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Mood.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct MoodAttributes {
	__unsafe_unretained NSString *name;
} MoodAttributes;

extern const struct MoodRelationships {
} MoodRelationships;

extern const struct MoodFetchedProperties {
} MoodFetchedProperties;




@interface MoodID : NSManagedObjectID {}
@end

@interface _Mood : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MoodID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;






@end

@interface _Mood (CoreDataGeneratedAccessors)

@end

@interface _Mood (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




@end
