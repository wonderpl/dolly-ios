// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comment.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct CommentAttributes {
	__unsafe_unretained NSString *commentText;
	__unsafe_unretained NSString *dateAdded;
	__unsafe_unretained NSString *displayName;
	__unsafe_unretained NSString *localData;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *thumbnailUrl;
	__unsafe_unretained NSString *userId;
	__unsafe_unretained NSString *validated;
	__unsafe_unretained NSString *videoInstanceId;
} CommentAttributes;

extern const struct CommentRelationships {
} CommentRelationships;

extern const struct CommentFetchedProperties {
} CommentFetchedProperties;












@interface CommentID : NSManagedObjectID {}
@end

@interface _Comment : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommentID*)objectID;





@property (nonatomic, strong) NSString* commentText;



//- (BOOL)validateCommentText:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateAdded;



//- (BOOL)validateDateAdded:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* displayName;



//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* localData;



@property BOOL localDataValue;
- (BOOL)localDataValue;
- (void)setLocalDataValue:(BOOL)value_;

//- (BOOL)validateLocalData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int32_t positionValue;
- (int32_t)positionValue;
- (void)setPositionValue:(int32_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailUrl;



//- (BOOL)validateThumbnailUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userId;



//- (BOOL)validateUserId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* validated;



@property BOOL validatedValue;
- (BOOL)validatedValue;
- (void)setValidatedValue:(BOOL)value_;

//- (BOOL)validateValidated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoInstanceId;



//- (BOOL)validateVideoInstanceId:(id*)value_ error:(NSError**)error_;






@end

@interface _Comment (CoreDataGeneratedAccessors)

@end

@interface _Comment (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCommentText;
- (void)setPrimitiveCommentText:(NSString*)value;




- (NSDate*)primitiveDateAdded;
- (void)setPrimitiveDateAdded:(NSDate*)value;




- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;




- (NSNumber*)primitiveLocalData;
- (void)setPrimitiveLocalData:(NSNumber*)value;

- (BOOL)primitiveLocalDataValue;
- (void)setPrimitiveLocalDataValue:(BOOL)value_;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int32_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int32_t)value_;




- (NSString*)primitiveThumbnailUrl;
- (void)setPrimitiveThumbnailUrl:(NSString*)value;




- (NSString*)primitiveUserId;
- (void)setPrimitiveUserId:(NSString*)value;




- (NSNumber*)primitiveValidated;
- (void)setPrimitiveValidated:(NSNumber*)value;

- (BOOL)primitiveValidatedValue;
- (void)setPrimitiveValidatedValue:(BOOL)value_;




- (NSString*)primitiveVideoInstanceId;
- (void)setPrimitiveVideoInstanceId:(NSString*)value;




@end
