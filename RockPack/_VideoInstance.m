// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to VideoInstance.m instead.

#import "_VideoInstance.h"

const struct VideoInstanceAttributes VideoInstanceAttributes = {
	.commentCount = @"commentCount",
	.dateAdded = @"dateAdded",
	.dateOfDayAdded = @"dateOfDayAdded",
	.label = @"label",
	.position = @"position",
	.title = @"title",
};

const struct VideoInstanceRelationships VideoInstanceRelationships = {
	.channel = @"channel",
	.starrers = @"starrers",
	.video = @"video",
};

const struct VideoInstanceFetchedProperties VideoInstanceFetchedProperties = {
};

@implementation VideoInstanceID
@end

@implementation _VideoInstance

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"VideoInstance" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"VideoInstance";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"VideoInstance" inManagedObjectContext:moc_];
}

- (VideoInstanceID*)objectID {
	return (VideoInstanceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"commentCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"commentCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic commentCount;



- (int32_t)commentCountValue {
	NSNumber *result = [self commentCount];
	return [result intValue];
}

- (void)setCommentCountValue:(int32_t)value_ {
	[self setCommentCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCommentCountValue {
	NSNumber *result = [self primitiveCommentCount];
	return [result intValue];
}

- (void)setPrimitiveCommentCountValue:(int32_t)value_ {
	[self setPrimitiveCommentCount:[NSNumber numberWithInt:value_]];
}





@dynamic dateAdded;






@dynamic dateOfDayAdded;






@dynamic label;






@dynamic position;



- (int64_t)positionValue {
	NSNumber *result = [self position];
	return [result longLongValue];
}

- (void)setPositionValue:(int64_t)value_ {
	[self setPosition:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitivePositionValue {
	NSNumber *result = [self primitivePosition];
	return [result longLongValue];
}

- (void)setPrimitivePositionValue:(int64_t)value_ {
	[self setPrimitivePosition:[NSNumber numberWithLongLong:value_]];
}





@dynamic title;






@dynamic channel;

	

@dynamic starrers;

	
- (NSMutableOrderedSet*)starrersSet {
	[self willAccessValueForKey:@"starrers"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"starrers"];
  
	[self didAccessValueForKey:@"starrers"];
	return result;
}
	

@dynamic video;

	






@end
