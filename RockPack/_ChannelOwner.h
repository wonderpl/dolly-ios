// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelOwner.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct ChannelOwnerAttributes {
	__unsafe_unretained NSString *channelOwnerDescription;
	__unsafe_unretained NSString *coverPhotoURL;
	__unsafe_unretained NSString *displayName;
	__unsafe_unretained NSString *followersTotalCount;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *subscribedByUser;
	__unsafe_unretained NSString *subscribersCount;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *totalVideosValueChannel;
	__unsafe_unretained NSString *totalVideosValueSubscriptions;
	__unsafe_unretained NSString *username;
} ChannelOwnerAttributes;

extern const struct ChannelOwnerRelationships {
	__unsafe_unretained NSString *channels;
	__unsafe_unretained NSString *starred;
	__unsafe_unretained NSString *subscriptions;
} ChannelOwnerRelationships;

extern const struct ChannelOwnerFetchedProperties {
} ChannelOwnerFetchedProperties;

@class Channel;
@class VideoInstance;
@class Channel;













@interface ChannelOwnerID : NSManagedObjectID {}
@end

@interface _ChannelOwner : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChannelOwnerID*)objectID;





@property (nonatomic, strong) NSString* channelOwnerDescription;



//- (BOOL)validateChannelOwnerDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* coverPhotoURL;



//- (BOOL)validateCoverPhotoURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* displayName;



//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* followersTotalCount;



@property int64_t followersTotalCountValue;
- (int64_t)followersTotalCountValue;
- (void)setFollowersTotalCountValue:(int64_t)value_;

//- (BOOL)validateFollowersTotalCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* totalVideosValueChannel;



@property int64_t totalVideosValueChannelValue;
- (int64_t)totalVideosValueChannelValue;
- (void)setTotalVideosValueChannelValue:(int64_t)value_;

//- (BOOL)validateTotalVideosValueChannel:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* totalVideosValueSubscriptions;



@property int64_t totalVideosValueSubscriptionsValue;
- (int64_t)totalVideosValueSubscriptionsValue;
- (void)setTotalVideosValueSubscriptionsValue:(int64_t)value_;

//- (BOOL)validateTotalVideosValueSubscriptions:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet *channels;

- (NSMutableOrderedSet*)channelsSet;




@property (nonatomic, strong) NSOrderedSet *starred;

- (NSMutableOrderedSet*)starredSet;




@property (nonatomic, strong) NSOrderedSet *subscriptions;

- (NSMutableOrderedSet*)subscriptionsSet;





@end

@interface _ChannelOwner (CoreDataGeneratedAccessors)

- (void)addChannels:(NSOrderedSet*)value_;
- (void)removeChannels:(NSOrderedSet*)value_;
- (void)addChannelsObject:(Channel*)value_;
- (void)removeChannelsObject:(Channel*)value_;

- (void)addStarred:(NSOrderedSet*)value_;
- (void)removeStarred:(NSOrderedSet*)value_;
- (void)addStarredObject:(VideoInstance*)value_;
- (void)removeStarredObject:(VideoInstance*)value_;

- (void)addSubscriptions:(NSOrderedSet*)value_;
- (void)removeSubscriptions:(NSOrderedSet*)value_;
- (void)addSubscriptionsObject:(Channel*)value_;
- (void)removeSubscriptionsObject:(Channel*)value_;

@end

@interface _ChannelOwner (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveChannelOwnerDescription;
- (void)setPrimitiveChannelOwnerDescription:(NSString*)value;




- (NSString*)primitiveCoverPhotoURL;
- (void)setPrimitiveCoverPhotoURL:(NSString*)value;




- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;




- (NSNumber*)primitiveFollowersTotalCount;
- (void)setPrimitiveFollowersTotalCount:(NSNumber*)value;

- (int64_t)primitiveFollowersTotalCountValue;
- (void)setPrimitiveFollowersTotalCountValue:(int64_t)value_;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSNumber*)primitiveSubscribedByUser;
- (void)setPrimitiveSubscribedByUser:(NSNumber*)value;

- (BOOL)primitiveSubscribedByUserValue;
- (void)setPrimitiveSubscribedByUserValue:(BOOL)value_;




- (NSNumber*)primitiveSubscribersCount;
- (void)setPrimitiveSubscribersCount:(NSNumber*)value;

- (int64_t)primitiveSubscribersCountValue;
- (void)setPrimitiveSubscribersCountValue:(int64_t)value_;




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;




- (NSNumber*)primitiveTotalVideosValueChannel;
- (void)setPrimitiveTotalVideosValueChannel:(NSNumber*)value;

- (int64_t)primitiveTotalVideosValueChannelValue;
- (void)setPrimitiveTotalVideosValueChannelValue:(int64_t)value_;




- (NSNumber*)primitiveTotalVideosValueSubscriptions;
- (void)setPrimitiveTotalVideosValueSubscriptions:(NSNumber*)value;

- (int64_t)primitiveTotalVideosValueSubscriptionsValue;
- (void)setPrimitiveTotalVideosValueSubscriptionsValue:(int64_t)value_;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (NSMutableOrderedSet*)primitiveChannels;
- (void)setPrimitiveChannels:(NSMutableOrderedSet*)value;



- (NSMutableOrderedSet*)primitiveStarred;
- (void)setPrimitiveStarred:(NSMutableOrderedSet*)value;



- (NSMutableOrderedSet*)primitiveSubscriptions;
- (void)setPrimitiveSubscriptions:(NSMutableOrderedSet*)value;


@end
