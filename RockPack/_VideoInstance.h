// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to VideoInstance.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct VideoInstanceAttributes {
	__unsafe_unretained NSString *dateAdded;
	__unsafe_unretained NSString *label;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *title;
} VideoInstanceAttributes;

extern const struct VideoInstanceRelationships {
	__unsafe_unretained NSString *channel;
	__unsafe_unretained NSString *originator;
	__unsafe_unretained NSString *starrers;
	__unsafe_unretained NSString *video;
	__unsafe_unretained NSString *videoOwner;
} VideoInstanceRelationships;

extern const struct VideoInstanceFetchedProperties {
} VideoInstanceFetchedProperties;

@class Channel;
@class ChannelOwner;
@class ChannelOwner;
@class Video;
@class ChannelOwner;






@interface VideoInstanceID : NSManagedObjectID {}
@end

@interface _VideoInstance : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (VideoInstanceID*)objectID;





@property (nonatomic, strong) NSDate* dateAdded;



//- (BOOL)validateDateAdded:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* label;



//- (BOOL)validateLabel:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Channel *channel;

//- (BOOL)validateChannel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) ChannelOwner *originator;

//- (BOOL)validateOriginator:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSOrderedSet *starrers;

- (NSMutableOrderedSet*)starrersSet;




@property (nonatomic, strong) Video *video;

//- (BOOL)validateVideo:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) ChannelOwner *videoOwner;

//- (BOOL)validateVideoOwner:(id*)value_ error:(NSError**)error_;





@end

@interface _VideoInstance (CoreDataGeneratedAccessors)

- (void)addStarrers:(NSOrderedSet*)value_;
- (void)removeStarrers:(NSOrderedSet*)value_;
- (void)addStarrersObject:(ChannelOwner*)value_;
- (void)removeStarrersObject:(ChannelOwner*)value_;

@end

@interface _VideoInstance (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDateAdded;
- (void)setPrimitiveDateAdded:(NSDate*)value;




- (NSString*)primitiveLabel;
- (void)setPrimitiveLabel:(NSString*)value;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (Channel*)primitiveChannel;
- (void)setPrimitiveChannel:(Channel*)value;



- (ChannelOwner*)primitiveOriginator;
- (void)setPrimitiveOriginator:(ChannelOwner*)value;



- (NSMutableOrderedSet*)primitiveStarrers;
- (void)setPrimitiveStarrers:(NSMutableOrderedSet*)value;



- (Video*)primitiveVideo;
- (void)setPrimitiveVideo:(Video*)value;



- (ChannelOwner*)primitiveVideoOwner;
- (void)setPrimitiveVideoOwner:(ChannelOwner*)value;


@end
