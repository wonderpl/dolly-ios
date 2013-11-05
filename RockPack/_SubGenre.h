// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SubGenre.h instead.

@import CoreData;
#import "Genre.h"

extern const struct SubGenreAttributes {
	__unsafe_unretained NSString *isDefault;
} SubGenreAttributes;

extern const struct SubGenreRelationships {
	__unsafe_unretained NSString *genre;
} SubGenreRelationships;

extern const struct SubGenreFetchedProperties {
} SubGenreFetchedProperties;

@class Genre;



@interface SubGenreID : NSManagedObjectID {}
@end

@interface _SubGenre : Genre {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SubGenreID*)objectID;





@property (nonatomic, strong) NSNumber* isDefault;



@property BOOL isDefaultValue;
- (BOOL)isDefaultValue;
- (void)setIsDefaultValue:(BOOL)value_;

//- (BOOL)validateIsDefault:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Genre *genre;

//- (BOOL)validateGenre:(id*)value_ error:(NSError**)error_;





@end

@interface _SubGenre (CoreDataGeneratedAccessors)

@end

@interface _SubGenre (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsDefault;
- (void)setPrimitiveIsDefault:(NSNumber*)value;

- (BOOL)primitiveIsDefaultValue;
- (void)setPrimitiveIsDefaultValue:(BOOL)value_;





- (Genre*)primitiveGenre;
- (void)setPrimitiveGenre:(Genre*)value;


@end
