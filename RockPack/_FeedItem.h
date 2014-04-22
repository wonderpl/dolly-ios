// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FeedItem.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct FeedItemAttributes {
	__unsafe_unretained NSString *channelOwnerId;
	__unsafe_unretained NSString *dateAdded;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *resourceType;
	__unsafe_unretained NSString *title;
} FeedItemAttributes;

extern const struct FeedItemRelationships {
} FeedItemRelationships;

extern const struct FeedItemFetchedProperties {
} FeedItemFetchedProperties;








@interface FeedItemID : NSManagedObjectID {}
@end

@interface _FeedItem : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FeedItemID*)objectID;





@property (nonatomic, strong) NSString* channelOwnerId;



//- (BOOL)validateChannelOwnerId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateAdded;



//- (BOOL)validateDateAdded:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* resourceType;



@property int32_t resourceTypeValue;
- (int32_t)resourceTypeValue;
- (void)setResourceTypeValue:(int32_t)value_;

//- (BOOL)validateResourceType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;






@end

@interface _FeedItem (CoreDataGeneratedAccessors)

@end

@interface _FeedItem (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveChannelOwnerId;
- (void)setPrimitiveChannelOwnerId:(NSString*)value;




- (NSDate*)primitiveDateAdded;
- (void)setPrimitiveDateAdded:(NSDate*)value;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSNumber*)primitiveResourceType;
- (void)setPrimitiveResourceType:(NSNumber*)value;

- (int32_t)primitiveResourceTypeValue;
- (void)setPrimitiveResourceTypeValue:(int32_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




@end
