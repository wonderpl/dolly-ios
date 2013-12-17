// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to VideoInstance.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct VideoInstanceAttributes {
	__unsafe_unretained NSString *commentCount;
	__unsafe_unretained NSString *dateAdded;
	__unsafe_unretained NSString *dateOfDayAdded;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *title;
} VideoInstanceAttributes;

extern const struct VideoInstanceRelationships {
	__unsafe_unretained NSString *channel;
	__unsafe_unretained NSString *starrers;
	__unsafe_unretained NSString *video;
} VideoInstanceRelationships;

extern const struct VideoInstanceFetchedProperties {
} VideoInstanceFetchedProperties;

@class Channel;
@class ChannelOwner;
@class Video;







@interface VideoInstanceID : NSManagedObjectID {}
@end

@interface _VideoInstance : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (VideoInstanceID*)objectID;





@property (nonatomic, strong) NSNumber* commentCount;



@property int32_t commentCountValue;
- (int32_t)commentCountValue;
- (void)setCommentCountValue:(int32_t)value_;

//- (BOOL)validateCommentCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateAdded;



//- (BOOL)validateDateAdded:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateOfDayAdded;



//- (BOOL)validateDateOfDayAdded:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Channel *channel;

//- (BOOL)validateChannel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSOrderedSet *starrers;

- (NSMutableOrderedSet*)starrersSet;




@property (nonatomic, strong) Video *video;

//- (BOOL)validateVideo:(id*)value_ error:(NSError**)error_;





@end

@interface _VideoInstance (CoreDataGeneratedAccessors)

- (void)addStarrers:(NSOrderedSet*)value_;
- (void)removeStarrers:(NSOrderedSet*)value_;
- (void)addStarrersObject:(ChannelOwner*)value_;
- (void)removeStarrersObject:(ChannelOwner*)value_;

@end

@interface _VideoInstance (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCommentCount;
- (void)setPrimitiveCommentCount:(NSNumber*)value;

- (int32_t)primitiveCommentCountValue;
- (void)setPrimitiveCommentCountValue:(int32_t)value_;




- (NSDate*)primitiveDateAdded;
- (void)setPrimitiveDateAdded:(NSDate*)value;




- (NSDate*)primitiveDateOfDayAdded;
- (void)setPrimitiveDateOfDayAdded:(NSDate*)value;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (Channel*)primitiveChannel;
- (void)setPrimitiveChannel:(Channel*)value;



- (NSMutableOrderedSet*)primitiveStarrers;
- (void)setPrimitiveStarrers:(NSMutableOrderedSet*)value;



- (Video*)primitiveVideo;
- (void)setPrimitiveVideo:(Video*)value;


@end
