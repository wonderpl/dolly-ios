// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct ChannelAttributes {
	__unsafe_unretained NSString *categoryId;
	__unsafe_unretained NSString *channelDescription;
	__unsafe_unretained NSString *datePublished;
	__unsafe_unretained NSString *eCommerceURL;
	__unsafe_unretained NSString *favourites;
	__unsafe_unretained NSString *lastUpdated;
	__unsafe_unretained NSString *popular;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *public;
	__unsafe_unretained NSString *resourceURL;
	__unsafe_unretained NSString *subscribedByUser;
	__unsafe_unretained NSString *subscribersCount;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *totalVideosValue;
} ChannelAttributes;

extern const struct ChannelRelationships {
	__unsafe_unretained NSString *channelCover;
	__unsafe_unretained NSString *channelOwner;
	__unsafe_unretained NSString *subscribers;
	__unsafe_unretained NSString *videoInstances;
} ChannelRelationships;

extern const struct ChannelFetchedProperties {
} ChannelFetchedProperties;

@class ChannelCover;
@class ChannelOwner;
@class ChannelOwner;
@class VideoInstance;
















@interface ChannelID : NSManagedObjectID {}
@end

@interface _Channel : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChannelID*)objectID;





@property (nonatomic, strong) NSString* categoryId;



//- (BOOL)validateCategoryId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* channelDescription;



//- (BOOL)validateChannelDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* datePublished;



//- (BOOL)validateDatePublished:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* eCommerceURL;



//- (BOOL)validateECommerceURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* favourites;



@property BOOL favouritesValue;
- (BOOL)favouritesValue;
- (void)setFavouritesValue:(BOOL)value_;

//- (BOOL)validateFavourites:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastUpdated;



//- (BOOL)validateLastUpdated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* popular;



@property BOOL popularValue;
- (BOOL)popularValue;
- (void)setPopularValue:(BOOL)value_;

//- (BOOL)validatePopular:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* public;



@property BOOL publicValue;
- (BOOL)publicValue;
- (void)setPublicValue:(BOOL)value_;

//- (BOOL)validatePublic:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* resourceURL;



//- (BOOL)validateResourceURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* subscribedByUser;



@property BOOL subscribedByUserValue;
- (BOOL)subscribedByUserValue;
- (void)setSubscribedByUserValue:(BOOL)value_;

//- (BOOL)validateSubscribedByUser:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* subscribersCount;



@property int64_t subscribersCountValue;
- (int64_t)subscribersCountValue;
- (void)setSubscribersCountValue:(int64_t)value_;

//- (BOOL)validateSubscribersCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* totalVideosValue;



@property int64_t totalVideosValueValue;
- (int64_t)totalVideosValueValue;
- (void)setTotalVideosValueValue:(int64_t)value_;

//- (BOOL)validateTotalVideosValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) ChannelCover *channelCover;

//- (BOOL)validateChannelCover:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) ChannelOwner *channelOwner;

//- (BOOL)validateChannelOwner:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *subscribers;

- (NSMutableSet*)subscribersSet;




@property (nonatomic, strong) NSOrderedSet *videoInstances;

- (NSMutableOrderedSet*)videoInstancesSet;





@end

@interface _Channel (CoreDataGeneratedAccessors)

- (void)addSubscribers:(NSSet*)value_;
- (void)removeSubscribers:(NSSet*)value_;
- (void)addSubscribersObject:(ChannelOwner*)value_;
- (void)removeSubscribersObject:(ChannelOwner*)value_;

- (void)addVideoInstances:(NSOrderedSet*)value_;
- (void)removeVideoInstances:(NSOrderedSet*)value_;
- (void)addVideoInstancesObject:(VideoInstance*)value_;
- (void)removeVideoInstancesObject:(VideoInstance*)value_;

@end

@interface _Channel (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCategoryId;
- (void)setPrimitiveCategoryId:(NSString*)value;




- (NSString*)primitiveChannelDescription;
- (void)setPrimitiveChannelDescription:(NSString*)value;




- (NSDate*)primitiveDatePublished;
- (void)setPrimitiveDatePublished:(NSDate*)value;




- (NSString*)primitiveECommerceURL;
- (void)setPrimitiveECommerceURL:(NSString*)value;




- (NSNumber*)primitiveFavourites;
- (void)setPrimitiveFavourites:(NSNumber*)value;

- (BOOL)primitiveFavouritesValue;
- (void)setPrimitiveFavouritesValue:(BOOL)value_;




- (NSDate*)primitiveLastUpdated;
- (void)setPrimitiveLastUpdated:(NSDate*)value;




- (NSNumber*)primitivePopular;
- (void)setPrimitivePopular:(NSNumber*)value;

- (BOOL)primitivePopularValue;
- (void)setPrimitivePopularValue:(BOOL)value_;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSNumber*)primitivePublic;
- (void)setPrimitivePublic:(NSNumber*)value;

- (BOOL)primitivePublicValue;
- (void)setPrimitivePublicValue:(BOOL)value_;




- (NSString*)primitiveResourceURL;
- (void)setPrimitiveResourceURL:(NSString*)value;




- (NSNumber*)primitiveSubscribedByUser;
- (void)setPrimitiveSubscribedByUser:(NSNumber*)value;

- (BOOL)primitiveSubscribedByUserValue;
- (void)setPrimitiveSubscribedByUserValue:(BOOL)value_;




- (NSNumber*)primitiveSubscribersCount;
- (void)setPrimitiveSubscribersCount:(NSNumber*)value;

- (int64_t)primitiveSubscribersCountValue;
- (void)setPrimitiveSubscribersCountValue:(int64_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSNumber*)primitiveTotalVideosValue;
- (void)setPrimitiveTotalVideosValue:(NSNumber*)value;

- (int64_t)primitiveTotalVideosValueValue;
- (void)setPrimitiveTotalVideosValueValue:(int64_t)value_;





- (ChannelCover*)primitiveChannelCover;
- (void)setPrimitiveChannelCover:(ChannelCover*)value;



- (ChannelOwner*)primitiveChannelOwner;
- (void)setPrimitiveChannelOwner:(ChannelOwner*)value;



- (NSMutableSet*)primitiveSubscribers;
- (void)setPrimitiveSubscribers:(NSMutableSet*)value;



- (NSMutableOrderedSet*)primitiveVideoInstances;
- (void)setPrimitiveVideoInstances:(NSMutableOrderedSet*)value;


@end
