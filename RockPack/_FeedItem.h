// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FeedItem.h instead.

@import CoreData;
#import "AbstractCommon.h"

extern const struct FeedItemAttributes {
	__unsafe_unretained NSString *channelOwnerId;
	__unsafe_unretained NSString *dateAdded;
	__unsafe_unretained NSString *itemCount;
	__unsafe_unretained NSString *itemType;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *resourceId;
	__unsafe_unretained NSString *resourceType;
	__unsafe_unretained NSString *title;
} FeedItemAttributes;

extern const struct FeedItemRelationships {
	__unsafe_unretained NSString *aggregate;
	__unsafe_unretained NSString *feedItems;
} FeedItemRelationships;

extern const struct FeedItemFetchedProperties {
} FeedItemFetchedProperties;

@class FeedItem;
@class FeedItem;










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





@property (nonatomic, strong) NSNumber* itemCount;



@property int32_t itemCountValue;
- (int32_t)itemCountValue;
- (void)setItemCountValue:(int32_t)value_;

//- (BOOL)validateItemCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* itemType;



@property int32_t itemTypeValue;
- (int32_t)itemTypeValue;
- (void)setItemTypeValue:(int32_t)value_;

//- (BOOL)validateItemType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* resourceId;



//- (BOOL)validateResourceId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* resourceType;



@property int32_t resourceTypeValue;
- (int32_t)resourceTypeValue;
- (void)setResourceTypeValue:(int32_t)value_;

//- (BOOL)validateResourceType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) FeedItem *aggregate;

//- (BOOL)validateAggregate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *feedItems;

- (NSMutableSet*)feedItemsSet;





@end

@interface _FeedItem (CoreDataGeneratedAccessors)

- (void)addFeedItems:(NSSet*)value_;
- (void)removeFeedItems:(NSSet*)value_;
- (void)addFeedItemsObject:(FeedItem*)value_;
- (void)removeFeedItemsObject:(FeedItem*)value_;

@end

@interface _FeedItem (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveChannelOwnerId;
- (void)setPrimitiveChannelOwnerId:(NSString*)value;




- (NSDate*)primitiveDateAdded;
- (void)setPrimitiveDateAdded:(NSDate*)value;




- (NSNumber*)primitiveItemCount;
- (void)setPrimitiveItemCount:(NSNumber*)value;

- (int32_t)primitiveItemCountValue;
- (void)setPrimitiveItemCountValue:(int32_t)value_;




- (NSNumber*)primitiveItemType;
- (void)setPrimitiveItemType:(NSNumber*)value;

- (int32_t)primitiveItemTypeValue;
- (void)setPrimitiveItemTypeValue:(int32_t)value_;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSString*)primitiveResourceId;
- (void)setPrimitiveResourceId:(NSString*)value;




- (NSNumber*)primitiveResourceType;
- (void)setPrimitiveResourceType:(NSNumber*)value;

- (int32_t)primitiveResourceTypeValue;
- (void)setPrimitiveResourceTypeValue:(int32_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (FeedItem*)primitiveAggregate;
- (void)setPrimitiveAggregate:(FeedItem*)value;



- (NSMutableSet*)primitiveFeedItems;
- (void)setPrimitiveFeedItems:(NSMutableSet*)value;


@end
