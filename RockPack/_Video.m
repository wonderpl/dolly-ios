// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.m instead.

#import "_Video.h"

const struct VideoAttributes VideoAttributes = {
	.categoryId = @"categoryId",
	.dateUploaded = @"dateUploaded",
	.duration = @"duration",
	.linkTitle = @"linkTitle",
	.linkURL = @"linkURL",
	.source = @"source",
	.sourceId = @"sourceId",
	.sourceUsername = @"sourceUsername",
	.thumbnailURL = @"thumbnailURL",
	.videoDescription = @"videoDescription",
	.viewCount = @"viewCount",
	.viewedByUser = @"viewedByUser",
};

const struct VideoRelationships VideoRelationships = {
	.videoAnnotations = @"videoAnnotations",
	.videoInstances = @"videoInstances",
};

const struct VideoFetchedProperties VideoFetchedProperties = {
};

@implementation VideoID
@end

@implementation _Video

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Video";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Video" inManagedObjectContext:moc_];
}

- (VideoID*)objectID {
	return (VideoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"durationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"duration"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"viewCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"viewCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"viewedByUserValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"viewedByUser"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic categoryId;






@dynamic dateUploaded;






@dynamic duration;



- (int64_t)durationValue {
	NSNumber *result = [self duration];
	return [result longLongValue];
}

- (void)setDurationValue:(int64_t)value_ {
	[self setDuration:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveDurationValue {
	NSNumber *result = [self primitiveDuration];
	return [result longLongValue];
}

- (void)setPrimitiveDurationValue:(int64_t)value_ {
	[self setPrimitiveDuration:[NSNumber numberWithLongLong:value_]];
}





@dynamic linkTitle;






@dynamic linkURL;






@dynamic source;






@dynamic sourceId;






@dynamic sourceUsername;






@dynamic thumbnailURL;






@dynamic videoDescription;






@dynamic viewCount;



- (int64_t)viewCountValue {
	NSNumber *result = [self viewCount];
	return [result longLongValue];
}

- (void)setViewCountValue:(int64_t)value_ {
	[self setViewCount:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveViewCountValue {
	NSNumber *result = [self primitiveViewCount];
	return [result longLongValue];
}

- (void)setPrimitiveViewCountValue:(int64_t)value_ {
	[self setPrimitiveViewCount:[NSNumber numberWithLongLong:value_]];
}





@dynamic viewedByUser;



- (BOOL)viewedByUserValue {
	NSNumber *result = [self viewedByUser];
	return [result boolValue];
}

- (void)setViewedByUserValue:(BOOL)value_ {
	[self setViewedByUser:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveViewedByUserValue {
	NSNumber *result = [self primitiveViewedByUser];
	return [result boolValue];
}

- (void)setPrimitiveViewedByUserValue:(BOOL)value_ {
	[self setPrimitiveViewedByUser:[NSNumber numberWithBool:value_]];
}





@dynamic videoAnnotations;

	
- (NSMutableSet*)videoAnnotationsSet {
	[self willAccessValueForKey:@"videoAnnotations"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"videoAnnotations"];
  
	[self didAccessValueForKey:@"videoAnnotations"];
	return result;
}
	

@dynamic videoInstances;

	
- (NSMutableSet*)videoInstancesSet {
	[self willAccessValueForKey:@"videoInstances"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"videoInstances"];
  
	[self didAccessValueForKey:@"videoInstances"];
	return result;
}
	






@end
