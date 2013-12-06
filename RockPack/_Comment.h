// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comment.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct CommentAttributes {
	__unsafe_unretained NSString *commentText;
	__unsafe_unretained NSString *dateAdded;
	__unsafe_unretained NSString *displayName;
	__unsafe_unretained NSString *thumbnailUrl;
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





@property (nonatomic, strong) NSString* thumbnailUrl;



//- (BOOL)validateThumbnailUrl:(id*)value_ error:(NSError**)error_;






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




- (NSString*)primitiveThumbnailUrl;
- (void)setPrimitiveThumbnailUrl:(NSString*)value;




@end
