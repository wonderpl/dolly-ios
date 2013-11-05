// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Genre.h instead.

@import CoreData;
#import "AbstractCommon.h"

extern const struct GenreAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *priority;
} GenreAttributes;

extern const struct GenreRelationships {
	__unsafe_unretained NSString *subgenres;
} GenreRelationships;

extern const struct GenreFetchedProperties {
} GenreFetchedProperties;

@class SubGenre;




@interface GenreID : NSManagedObjectID {}
@end

@interface _Genre : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GenreID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* priority;



@property int32_t priorityValue;
- (int32_t)priorityValue;
- (void)setPriorityValue:(int32_t)value_;

//- (BOOL)validatePriority:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet *subgenres;

- (NSMutableOrderedSet*)subgenresSet;





@end

@interface _Genre (CoreDataGeneratedAccessors)

- (void)addSubgenres:(NSOrderedSet*)value_;
- (void)removeSubgenres:(NSOrderedSet*)value_;
- (void)addSubgenresObject:(SubGenre*)value_;
- (void)removeSubgenresObject:(SubGenre*)value_;

@end

@interface _Genre (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePriority;
- (void)setPrimitivePriority:(NSNumber*)value;

- (int32_t)primitivePriorityValue;
- (void)setPrimitivePriorityValue:(int32_t)value_;





- (NSMutableOrderedSet*)primitiveSubgenres;
- (void)setPrimitiveSubgenres:(NSMutableOrderedSet*)value;


@end
