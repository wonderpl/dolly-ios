// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to VideoAnnotation.m instead.

#import "_VideoAnnotation.h"

const struct VideoAnnotationAttributes VideoAnnotationAttributes = {
	.endTimestamp = @"endTimestamp",
	.height = @"height",
	.originX = @"originX",
	.originY = @"originY",
	.startTimestamp = @"startTimestamp",
	.url = @"url",
	.width = @"width",
};

const struct VideoAnnotationRelationships VideoAnnotationRelationships = {
	.video = @"video",
};

const struct VideoAnnotationFetchedProperties VideoAnnotationFetchedProperties = {
};

@implementation VideoAnnotationID
@end

@implementation _VideoAnnotation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"VideoAnnotation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"VideoAnnotation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"VideoAnnotation" inManagedObjectContext:moc_];
}

- (VideoAnnotationID*)objectID {
	return (VideoAnnotationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"endTimestampValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"endTimestamp"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"heightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"height"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"originXValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originX"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"originYValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originY"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"startTimestampValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"startTimestamp"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"widthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"width"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic endTimestamp;



- (int32_t)endTimestampValue {
	NSNumber *result = [self endTimestamp];
	return [result intValue];
}

- (void)setEndTimestampValue:(int32_t)value_ {
	[self setEndTimestamp:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveEndTimestampValue {
	NSNumber *result = [self primitiveEndTimestamp];
	return [result intValue];
}

- (void)setPrimitiveEndTimestampValue:(int32_t)value_ {
	[self setPrimitiveEndTimestamp:[NSNumber numberWithInt:value_]];
}





@dynamic height;



- (double)heightValue {
	NSNumber *result = [self height];
	return [result doubleValue];
}

- (void)setHeightValue:(double)value_ {
	[self setHeight:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveHeightValue {
	NSNumber *result = [self primitiveHeight];
	return [result doubleValue];
}

- (void)setPrimitiveHeightValue:(double)value_ {
	[self setPrimitiveHeight:[NSNumber numberWithDouble:value_]];
}





@dynamic originX;



- (double)originXValue {
	NSNumber *result = [self originX];
	return [result doubleValue];
}

- (void)setOriginXValue:(double)value_ {
	[self setOriginX:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveOriginXValue {
	NSNumber *result = [self primitiveOriginX];
	return [result doubleValue];
}

- (void)setPrimitiveOriginXValue:(double)value_ {
	[self setPrimitiveOriginX:[NSNumber numberWithDouble:value_]];
}





@dynamic originY;



- (double)originYValue {
	NSNumber *result = [self originY];
	return [result doubleValue];
}

- (void)setOriginYValue:(double)value_ {
	[self setOriginY:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveOriginYValue {
	NSNumber *result = [self primitiveOriginY];
	return [result doubleValue];
}

- (void)setPrimitiveOriginYValue:(double)value_ {
	[self setPrimitiveOriginY:[NSNumber numberWithDouble:value_]];
}





@dynamic startTimestamp;



- (int32_t)startTimestampValue {
	NSNumber *result = [self startTimestamp];
	return [result intValue];
}

- (void)setStartTimestampValue:(int32_t)value_ {
	[self setStartTimestamp:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveStartTimestampValue {
	NSNumber *result = [self primitiveStartTimestamp];
	return [result intValue];
}

- (void)setPrimitiveStartTimestampValue:(int32_t)value_ {
	[self setPrimitiveStartTimestamp:[NSNumber numberWithInt:value_]];
}





@dynamic url;






@dynamic width;



- (double)widthValue {
	NSNumber *result = [self width];
	return [result doubleValue];
}

- (void)setWidthValue:(double)value_ {
	[self setWidth:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveWidthValue {
	NSNumber *result = [self primitiveWidth];
	return [result doubleValue];
}

- (void)setPrimitiveWidthValue:(double)value_ {
	[self setPrimitiveWidth:[NSNumber numberWithDouble:value_]];
}





@dynamic video;

	






@end
