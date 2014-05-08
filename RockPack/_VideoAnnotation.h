// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to VideoAnnotation.h instead.

#import <CoreData/CoreData.h>


extern const struct VideoAnnotationAttributes {
	__unsafe_unretained NSString *endTimestamp;
	__unsafe_unretained NSString *height;
	__unsafe_unretained NSString *originX;
	__unsafe_unretained NSString *originY;
	__unsafe_unretained NSString *startTimestamp;
	__unsafe_unretained NSString *url;
	__unsafe_unretained NSString *width;
} VideoAnnotationAttributes;

extern const struct VideoAnnotationRelationships {
	__unsafe_unretained NSString *video;
} VideoAnnotationRelationships;

extern const struct VideoAnnotationFetchedProperties {
} VideoAnnotationFetchedProperties;

@class Video;









@interface VideoAnnotationID : NSManagedObjectID {}
@end

@interface _VideoAnnotation : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (VideoAnnotationID*)objectID;





@property (nonatomic, strong) NSNumber* endTimestamp;



@property int32_t endTimestampValue;
- (int32_t)endTimestampValue;
- (void)setEndTimestampValue:(int32_t)value_;

//- (BOOL)validateEndTimestamp:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* height;



@property double heightValue;
- (double)heightValue;
- (void)setHeightValue:(double)value_;

//- (BOOL)validateHeight:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* originX;



@property double originXValue;
- (double)originXValue;
- (void)setOriginXValue:(double)value_;

//- (BOOL)validateOriginX:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* originY;



@property double originYValue;
- (double)originYValue;
- (void)setOriginYValue:(double)value_;

//- (BOOL)validateOriginY:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* startTimestamp;



@property int32_t startTimestampValue;
- (int32_t)startTimestampValue;
- (void)setStartTimestampValue:(int32_t)value_;

//- (BOOL)validateStartTimestamp:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* width;



@property double widthValue;
- (double)widthValue;
- (void)setWidthValue:(double)value_;

//- (BOOL)validateWidth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Video *video;

//- (BOOL)validateVideo:(id*)value_ error:(NSError**)error_;





@end

@interface _VideoAnnotation (CoreDataGeneratedAccessors)

@end

@interface _VideoAnnotation (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveEndTimestamp;
- (void)setPrimitiveEndTimestamp:(NSNumber*)value;

- (int32_t)primitiveEndTimestampValue;
- (void)setPrimitiveEndTimestampValue:(int32_t)value_;




- (NSNumber*)primitiveHeight;
- (void)setPrimitiveHeight:(NSNumber*)value;

- (double)primitiveHeightValue;
- (void)setPrimitiveHeightValue:(double)value_;




- (NSNumber*)primitiveOriginX;
- (void)setPrimitiveOriginX:(NSNumber*)value;

- (double)primitiveOriginXValue;
- (void)setPrimitiveOriginXValue:(double)value_;




- (NSNumber*)primitiveOriginY;
- (void)setPrimitiveOriginY:(NSNumber*)value;

- (double)primitiveOriginYValue;
- (void)setPrimitiveOriginYValue:(double)value_;




- (NSNumber*)primitiveStartTimestamp;
- (void)setPrimitiveStartTimestamp:(NSNumber*)value;

- (int32_t)primitiveStartTimestampValue;
- (void)setPrimitiveStartTimestampValue:(int32_t)value_;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;




- (NSNumber*)primitiveWidth;
- (void)setPrimitiveWidth:(NSNumber*)value;

- (double)primitiveWidthValue;
- (void)setPrimitiveWidthValue:(double)value_;





- (Video*)primitiveVideo;
- (void)setPrimitiveVideo:(Video*)value;


@end
