// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Recommendation.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct RecommendationAttributes {
	__unsafe_unretained NSString *avatarUrl;
	__unsafe_unretained NSString *categoryId;
	__unsafe_unretained NSString *descriptionText;
	__unsafe_unretained NSString *displayName;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *resourceUrl;
} RecommendationAttributes;

extern const struct RecommendationRelationships {
} RecommendationRelationships;

extern const struct RecommendationFetchedProperties {
} RecommendationFetchedProperties;









@interface RecommendationID : NSManagedObjectID {}
@end

@interface _Recommendation : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RecommendationID*)objectID;





@property (nonatomic, strong) NSString* avatarUrl;



//- (BOOL)validateAvatarUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* categoryId;



//- (BOOL)validateCategoryId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* descriptionText;



//- (BOOL)validateDescriptionText:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* displayName;



//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int32_t positionValue;
- (int32_t)positionValue;
- (void)setPositionValue:(int32_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* resourceUrl;



//- (BOOL)validateResourceUrl:(id*)value_ error:(NSError**)error_;






@end

@interface _Recommendation (CoreDataGeneratedAccessors)

@end

@interface _Recommendation (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAvatarUrl;
- (void)setPrimitiveAvatarUrl:(NSString*)value;




- (NSString*)primitiveCategoryId;
- (void)setPrimitiveCategoryId:(NSString*)value;




- (NSString*)primitiveDescriptionText;
- (void)setPrimitiveDescriptionText:(NSString*)value;




- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int32_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int32_t)value_;




- (NSString*)primitiveResourceUrl;
- (void)setPrimitiveResourceUrl:(NSString*)value;




@end
