// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AbstractCommon.h instead.

#import <CoreData/CoreData.h>


extern const struct AbstractCommonAttributes {
	__unsafe_unretained NSString *markedForDeletion;
	__unsafe_unretained NSString *uniqueId;
	__unsafe_unretained NSString *viewId;
} AbstractCommonAttributes;

extern const struct AbstractCommonRelationships {
} AbstractCommonRelationships;

extern const struct AbstractCommonFetchedProperties {
} AbstractCommonFetchedProperties;






@interface AbstractCommonID : NSManagedObjectID {}
@end

@interface _AbstractCommon : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AbstractCommonID*)objectID;





@property (nonatomic, strong) NSNumber* markedForDeletion;



@property BOOL markedForDeletionValue;
- (BOOL)markedForDeletionValue;
- (void)setMarkedForDeletionValue:(BOOL)value_;

//- (BOOL)validateMarkedForDeletion:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uniqueId;



//- (BOOL)validateUniqueId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* viewId;



//- (BOOL)validateViewId:(id*)value_ error:(NSError**)error_;






@end

@interface _AbstractCommon (CoreDataGeneratedAccessors)

@end

@interface _AbstractCommon (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveMarkedForDeletion;
- (void)setPrimitiveMarkedForDeletion:(NSNumber*)value;

- (BOOL)primitiveMarkedForDeletionValue;
- (void)setPrimitiveMarkedForDeletionValue:(BOOL)value_;




- (NSString*)primitiveUniqueId;
- (void)setPrimitiveUniqueId:(NSString*)value;




- (NSString*)primitiveViewId;
- (void)setPrimitiveViewId:(NSString*)value;




@end
