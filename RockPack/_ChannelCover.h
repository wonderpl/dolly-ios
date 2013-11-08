// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelCover.h instead.

#import <CoreData/CoreData.h>


extern const struct ChannelCoverAttributes {
	__unsafe_unretained NSString *endU;
	__unsafe_unretained NSString *endV;
	__unsafe_unretained NSString *imageUrl;
	__unsafe_unretained NSString *startU;
	__unsafe_unretained NSString *startV;
} ChannelCoverAttributes;

extern const struct ChannelCoverRelationships {
	__unsafe_unretained NSString *channel;
} ChannelCoverRelationships;

extern const struct ChannelCoverFetchedProperties {
} ChannelCoverFetchedProperties;

@class Channel;







@interface ChannelCoverID : NSManagedObjectID {}
@end

@interface _ChannelCover : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChannelCoverID*)objectID;





@property (nonatomic, strong) NSNumber* endU;



@property float endUValue;
- (float)endUValue;
- (void)setEndUValue:(float)value_;

//- (BOOL)validateEndU:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* endV;



@property float endVValue;
- (float)endVValue;
- (void)setEndVValue:(float)value_;

//- (BOOL)validateEndV:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* imageUrl;



//- (BOOL)validateImageUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* startU;



@property float startUValue;
- (float)startUValue;
- (void)setStartUValue:(float)value_;

//- (BOOL)validateStartU:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* startV;



@property float startVValue;
- (float)startVValue;
- (void)setStartVValue:(float)value_;

//- (BOOL)validateStartV:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Channel *channel;

//- (BOOL)validateChannel:(id*)value_ error:(NSError**)error_;





@end

@interface _ChannelCover (CoreDataGeneratedAccessors)

@end

@interface _ChannelCover (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveEndU;
- (void)setPrimitiveEndU:(NSNumber*)value;

- (float)primitiveEndUValue;
- (void)setPrimitiveEndUValue:(float)value_;




- (NSNumber*)primitiveEndV;
- (void)setPrimitiveEndV:(NSNumber*)value;

- (float)primitiveEndVValue;
- (void)setPrimitiveEndVValue:(float)value_;




- (NSString*)primitiveImageUrl;
- (void)setPrimitiveImageUrl:(NSString*)value;




- (NSNumber*)primitiveStartU;
- (void)setPrimitiveStartU:(NSNumber*)value;

- (float)primitiveStartUValue;
- (void)setPrimitiveStartUValue:(float)value_;




- (NSNumber*)primitiveStartV;
- (void)setPrimitiveStartV:(NSNumber*)value;

- (float)primitiveStartVValue;
- (void)setPrimitiveStartVValue:(float)value_;





- (Channel*)primitiveChannel;
- (void)setPrimitiveChannel:(Channel*)value;


@end
